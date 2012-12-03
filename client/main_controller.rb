require "xmlrpc/client"
require "socket"

require_relative "./contracts/main_controller_contracts"

# Controller object for the MainView object.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class MainController
  include MainControllerContracts
  def initialize(view, local_port)
    @view = view
    @local_port = local_port
    @winner = -1
  end

  # MAIN MENU SIGNALS

  # Application closed
  def gtk_main_quit
    Gtk.main_quit
    exit!
  end

  # Number of human players changed
  def on_humans_changed
    begin
      sum = @view.humans.text.to_i + @view.computers.text.to_i
      if @view.otto_radiobutton.active?
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
      @view.show_error_dialog
    end
  end

  # Number of computer players changed
  def on_computers_changed
    begin
      on_humans_changed()
    rescue Exception => e
      puts e.message
      @view.show_error_dialog
    end
  end

  # Radio button (for game mode) changed
  def on_mode_changed
    begin
      if @view.otto_radiobutton.active?
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
      @view.show_error_dialog
    end
  end

  # Start button clicked
  def on_start_clicked
    #begin
    #Set game type based on radio buttons
    if @view.connect4_radiobutton.active?
      game_type = "connect4"
    else
      game_type = "otto"
    end
    difficulty = 0
    if @view.easy.active?
      difficulty = 0.80
    elsif @view.medium.active?
      difficulty = 0.40
    end

    humans = @view.humans.text.to_i
    computers = @view.computers.text.to_i

    ip_address = ENV["HOSTNAME"]
    @player_name = @view.get_player_name
    game_name = @view.game_name.text
    if game_name == ""
      game_name = "Game " + Time.now.to_s
    end
    @id = get_rpc.create_game(game_name, humans, computers, difficulty, @player_name, game_type, ip_address, @local_port)

    players = get_rpc.get_players(@id)
    @view.initialize_players(players)

    @view.reset_board_images()
    #Then show the board
    @view.show_board(game_type + " Playing Area")
    start_win_timer()
    #rescue Exception => e
    #  puts e.message
    #  @view.show_error_dialog
    # end
    return true
  end

  def on_join_clicked
    @id = @view.games_list.selection.selected.get_value(1)
    ip_address = ENV["HOSTNAME"]
    @player_name = @view.get_player_name
    result = get_rpc.join_game(@id, @player_name, ip_address, @local_port)
    if !result
      return
    end
    players = get_rpc.get_players(@id)
    @view.initialize_players(players)
    grid, active_player = get_rpc.update(@id)
    @view.update(Marshal.load(grid), active_player)

    @view.reset_board_images()
    #Then show the board
    @view.show_board("ECE 421 Project 5")
    start_win_timer()
  end

  def on_refresh_clicked
    games = Marshal.load(get_rpc.get_open_games())
    @view.games_list.model.clear
    games.each { |id, name|
      row = @view.games_list.model.insert(0)
      row.set_value(0, name)
      row.set_value(1, id)
    }
  end

  def on_statistics_clicked
    @view.show_statistics
  end
  
  def on_statistics_close_clicked
    @view.hide_statistics
  end
  
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

  def set_win(win)
    @winner = win
  end

  def clean_up
    Gtk.timeout_remove(@win_thread)
  end

  def on_help_clicked
    @view.help.show()
  end

  def on_help_close
    @view.help.hide()
  end

  def on_delete_help
    @view.help.hide_on_delete()
  end

  # BOARD SIGNALS

  # Mouse clicked on one of the columns
  def on_eventbox1_button_release_event
    #begin
    get_rpc.make_move(@id, @player_name, @view.col_selected)
    # @view.update(Marshal.load(@server.get_update(@id)))
    #rescue Exception => e
    #  puts e.message
    #  @view.show_error_dialog
    #end
  end

  # Mouse hovered over one of the columns
  def on_eventbox1_motion_notify_event(widget,event)
    #begin
    #get the column
    @view.set_column_selected(event.x)
    #show corresponding arrow
    @view.show_arrow()
    #rescue Exception => e
    #  puts e.message
    #  @view.show_error_dialog
    #end
  end

  # Board hidden
  def on_board_delete_event
    @view.board.hide_on_delete()
  end

  # WIN DIALOG SIGNALS

  # Return to main menu button clicked
  def on_return_to_main_button_clicked
    @view.win_dialog.hide()
    @view.board.hide()
    @view.reset_board_images()
    @winner = -1
  end

  # Dialog hidden
  def on_win_dialog_delete_event
    @view.win_dialog.hide_on_delete()
  end

  def get_rpc
    server_object = XMLRPC::Client.new(@view.ip_address.text, "/", @view.port.text.to_i)
    return server_object.proxy("server")
  end
end