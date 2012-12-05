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
    pre_set_win(win)
    @winner = win
    post_set_win()
  end

  # MAIN MENU SIGNALS

  # Application closed
  def gtk_main_quit
    class_invariant()
    Gtk.main_quit
    exit!
  end

  # Number of players changed
  def on_players_changed
    class_invariant()
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
    class_invariant()
  end

  # Radio button (for game mode) changed
  def on_mode_changed
    class_invariant()
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
    class_invariant()
  end

  # Start button clicked
  def on_start_clicked
    class_invariant()
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
      @view.show_message_dialog("No connection to server")
    end
    class_invariant()
    return true
  end

  # Join button clicked
  def on_join_clicked
    class_invariant()
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
      @view.reset_board_images()
      grid, active_player = get_rpc.update(@id)
      @view.update(Marshal.load(grid), active_player)
      @view.show_board()
      start_win_timer()
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_message_dialog("No connection to server")
    end
    class_invariant()
  end

  # Refresh button clicked
  def on_refresh_clicked
    class_invariant()
    begin
      games = Marshal.load(get_rpc.get_open_games(@view.get_player_name))
      @view.games_list.model.clear
      games.each { |id, name|
        row = @view.games_list.model.insert(0)
        row.set_value(0, name)
        row.set_value(1, id)
      }
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_message_dialog("No connection to server")
    end
    class_invariant()
  end

  # Statistics button clicked
  def on_statistics_clicked
    class_invariant()
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
      @view.show_message_dialog("No connection to server")
    end
    class_invariant()
  end

  # Close button in statistics dialog clicked
  def on_statistics_close
    class_invariant()
    @view.hide_statistics_dialog
    class_invariant()
  end

  # Help button clicked
  def on_help_clicked
    class_invariant()
    @view.show_help()
    class_invariant()
  end

  # Close button in help dialog clicked
  def on_help_close
    class_invariant()
    @view.hide_help()
    class_invariant()
  end

  def on_message_close
    class_invariant()
    @view.hide_message_dialog()
    class_invariant()
  end

  # BOARD SIGNALS

  # Mouse clicked on one of the columns
  def on_column_clicked
    class_invariant()
    begin
      get_rpc.make_move(@id, @view.get_player_name, @view.col_selected)
      grid, active_player = get_rpc.update(@id)
      @view.update(Marshal.load(grid), active_player)
    rescue Exception => e
      puts e.message
      puts e.backtrace
      @view.show_error_dialog(e)
    end
    class_invariant()
  end

  # Mouse hovered over one of the columns
  def on_column_hover(widget, event)
    class_invariant()
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
    class_invariant()
  end

  # Board closed
  def on_board_close
    class_invariant()
    @view.hide_board()
    class_invariant()
  end

  # WIN DIALOG SIGNALS

  # Return to main menu button clicked within the win dialog
  def on_win_close
    class_invariant()
    @view.hide_win_dialog()
    @view.hide_board()
    @view.reset_board_images()
    @winner = -1
    class_invariant()
  end

  private

  # Win check function, runs in a timer that fires every second and verifies if
  # a win has occured. If so, makes appropriate view calls.
  def start_win_timer
    @win_thread = Gtk.timeout_add(500) {
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