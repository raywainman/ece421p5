require "xmlrpc/client"
require "socket"

require_relative "./contracts/main_controller_contracts"

# Controller object for the MainView object.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

class MainController
  include MainControllerContracts
  # Creates a new instance of the controller object. Accepts a view object and
  # the local port that the client's XMLRPC server is running on.
  def initialize(view, local_port)
    pre_initialize(view, local_port)
    @view = view
    @local_port = local_port
    @winner = -1
    @local_ip = ENV["HOSTNAME"]
    if @local_ip == nil
      @local_ip = Socket.gethostname
    end
    post_initialize()
  end

  # Notifies the controller that a winner has been determined. Will be shown
  # when the next win check timeout occurs.
  def set_win(win)
    @winner = win
  end

  # MAIN MENU SIGNALS

  # Application closed
  def gtk_main_quit
    Gtk.main_quit
    exit!
  end

  # Number of players changed
  def on_players_changed
    begin
      sum = @view.humans.text.to_i + @view.computers.text.to_i
      if @view.get_mode == "otto"
        if sum > 2
          @view.humans.text = 2.to_s
          @view.computers.text = 0.to_s
        elsif sum == 1
          @view.computers.text = 1.to_s
        end
      else
        if sum > 4
          difference = 4 - @view.humans.text.to_i
          @view.computers.text = difference.to_s
        elsif sum == 1
          @view.computers.text = 1.to_s
        end
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
  end

  # Radio button (for game mode) changed
  def on_mode_changed
    begin
      if @view.get_mode == "otto"
        if @view.humans.text.to_i >= 2
          @view.humans.text = 2.to_s
          @view.computers.text = 0.to_s
        end
        if @view.computers.text.to_i > 1
          @view.computers.text = 1.to_s
        end
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
  end

  # Start button clicked
  def on_start_clicked
    begin
      game_type = @view.get_mode
      difficulty = @view.get_difficulty
      humans = @view.humans.text.to_i
      computers = @view.computers.text.to_i
      player_name = @view.get_player_name
      game_name = @view.get_game_name
      # Create game
      @id = get_rpc.create_game(game_name, humans, computers, difficulty, player_name, game_type, @local_ip, @local_port)
      # Update view
      players = get_rpc.get_players(@id)
      @view.initialize_players(players)
      @view.reset_board_images()
      @view.show_board()
      start_win_timer()
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
    return true
  end

  # Join button clicked
  def on_join_clicked
    begin
      @id = @view.get_selected_game
      if @id == nil
        return
      end
      result = get_rpc.join_game(@id, @view.get_player_name, @local_ip, @local_port)
      if !result
        return
      end
      players = get_rpc.get_players(@id)
      @view.initialize_players(players)
      grid, active_player = get_rpc.update(@id)
      @view.update(Marshal.load(grid), active_player)
      @view.reset_board_images()
      @view.show_board()
      start_win_timer()
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
  end

  # Refresh button clicked
  def on_refresh_clicked
    begin
      games = Marshal.load(get_rpc.get_open_games(@view.get_player_name))
      @view.set_game_list(games)
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e.message)
    end
  end

  # Statistics button clicked
  def on_statistics_clicked
    begin
      @view.statistics_table.model.clear()
      leaderboard = Marshal.load(get_rpc.get_leaderboard())
      leaderboard.each { |player|
        row = @view.statistics_table.model.insert(leaderboard.size)
        row.set_value(0, player["NAME"])
        row.set_value(1, player["WINS"])
        row.set_value(2, player["LOSES"])
        row.set_value(3, player["DRAWS"])
        row.set_value(4, player["AVG_TOKENS"])
        row.set_value(5, player["AVG_TOKENS_WINS"])
      }
      @view.show_statistics_dialog
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
  end

  # Close button in statistics dialog clicked
  def on_statistics_close
    @view.hide_statistics_dialog
  end

  # Help button clicked
  def on_help_clicked
    @view.show_help()
  end

  # Close button in help dialog clicked
  def on_help_close
    @view.hide_help()
  end

  # BOARD SIGNALS

  # Mouse clicked on one of the columns
  def on_column_clicked
    begin
      get_rpc.make_move(@id, @view.get_player_name, @view.col_selected)
      @view.update(Marshal.load(get_rpc.update(@id)))
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
  end

  # Mouse hovered over one of the columns
  def on_column_hover(widget, event)
    begin
      #get the column
      @view.set_column_selected(event.x)
      #show corresponding arrow
      @view.show_arrow()
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
  end

  # WIN DIALOG SIGNALS

  # Return to main menu button clicked within the win dialog
  def on_win_close
    @view.hide_win_dialog()
    @view.hide_board()
    @view.reset_board_images()
    @winner = -1
  end

  private

  # Win check function, runs in a timer that fires every second and verifies if
  # a win has occured. If so, makes appropriate view calls.
  def start_win_timer
    @win_thread = Gtk.timeout_add(1000) {
      if @winner != -1 && @winner != 0
        @view.show_win(@winner.to_s)
        false
      elsif @winner == 0
        @view.show_tie()
        false
      else
        true
      end
    }
  end

  # Gets an RPC Client object which connects to the user-specified server.
  def get_rpc
    server_object = XMLRPC::Client.new(@view.get_ip, "/", @view.get_port)
    return server_object.proxy("server")
  end
end