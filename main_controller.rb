require_relative "./ai_player"
require_relative "./connect4"
require_relative "./game"
require_relative "./human_player"
require_relative "./otto"
require_relative "./contracts/main_controller_contracts"

# Controller object for the MainView object.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class MainController
  include MainControllerContracts
  def initialize(view)
    @view = view
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
    begin
      #Set game type based on radio buttons
      if @view.connect4_radiobutton.active?
        game_type = Connect4.instance
      else
        game_type = Otto.instance
      end
      players = []
      @view.humans.text.to_i.times {
        players << HumanPlayer.new
      }
      difficulty = 0
      if @view.easy.active?
        difficulty = 0.80
      elsif @view.medium.active?
        difficulty = 0.40
      end
      @view.computers.text.to_i.times {
        players << AIPlayer.new(difficulty)
      }
      @game = Game.new(game_type, players, @view)
      @view.reset_board_images()
      #Then show the board
      @view.show_board(game_type.game_name + " Playing Area")
    rescue Exception => e
      puts e.message
      @view.show_error_dialog
    end
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
    begin
      if !@game.is_column_full?(@view.col_selected)
        @game.make_move(@view.col_selected)
      end
    rescue Exception => e
      puts e.message
      @view.show_error_dialog
    end
  end

  # Mouse hovered over one of the columns
  def on_eventbox1_motion_notify_event(widget,event)
    begin
      #get the column
      @view.set_column_selected(event.x)
      #show corresponding arrow
      @view.show_arrow()
    rescue Exception => e
      puts e.message
      @view.show_error_dialog
    end
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
  end

  # Play again button clicked
  def on_playagain_clicked
    begin
      @game.reset
      @view.win_dialog.hide()
    rescue Exception => e
      puts e.message
      @view.show_error_dialog
    end
  end

  # Dialog hidden
  def on_win_dialog_delete_event
    @view.board.hide()
    @view.win_dialog.hide_on_delete()
  end
end