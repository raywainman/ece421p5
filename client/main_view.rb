require "rubygems"
require "gtk2"

require_relative "./main_controller"
require_relative "./contracts/main_view_contracts"

# User interface for the connect4/otto game

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

class MainView
  include MainViewContracts

  # Expose form widgets and other important components
  attr_reader :humans, :computers, :col_selected, :statistics_table, :games_list
  # Initializes GUI via .glade file and gets all the widgets
  def initialize()
    initialize_preconditions()
    Gtk.init
    @builder = Gtk::Builder::new
    @builder.add_from_file("./GUI.glade")
    get_all_widgets()
    @col_selected=0
    @ip_address.text = Socket.gethostname
    @port.text = "50500"
    initialize_postconditions()
  end

  # Sets the controller for this view and attaches all signal handlers
  def set_controller(controller)
    set_controller_preconditions(controller)
    @controller = controller
    @builder.connect_signals{ |handler| controller.method(handler) }
    set_controller_postconditions()
  end

  # Shows the main application window (the main menu)
  def show
    class_invariant()
    @builder.get_object("mainMenu").show()
    @humans.text = "1"
    @computers.text = "1"
    Gtk.main()
  end

  # Shows the board
  def show_board()
    class_invariant()
    @board.hide_on_delete()
    @board.show()
    @start_btn.sensitive = false
    @join_btn.sensitive  = false
    class_invariant()
  end

  # Hides the board
  def hide_board()
    class_invariant()
    @board.hide()
    @start_btn.sensitive = true
    @join_btn.sensitive = true
    class_invariant()
  end

  # Shows an error dialog with the given exception message
  def show_error_dialog(exception)
    class_invariant()
    @error_dialog_exception.text = exception.to_s
    @error_dialog.show()
    class_invariant()
  end

  # Shows the statistics dialog
  def show_statistics_dialog()
    class_invariant()
    @statistics_dialog.hide_on_delete()
    @statistics_dialog.show()
    class_invariant()
  end

  # Hides the statistics dialog
  def hide_statistics_dialog()
    class_invariant()
    @statistics_dialog.hide()
    class_invariant()
  end

  # Shows the help dialog
  def show_help()
    class_invariant()
    @help.hide_on_delete()
    @help.show()
    class_invariant()
  end

  # Hides the help dialog
  def hide_help()
    class_invariant()
    @help.hide()
    class_invariant()
  end

  # Shows the corresponding arrow based on the value stored in the class variable
  # @col_selected
  def show_arrow()
    class_invariant()
    #hide all arrows first
    @arrows.each { |arrow|
      arrow.hide
    }
    #Then show the one stored
    @arrows[@col_selected].show
    class_invariant()
  end

  # Method that modifies the global variable of the column selected
  # when passing the X coordinate. Called every time the mouse moves
  def set_column_selected(x)
    class_invariant()
    #get the window width
    board_width=@board.size[0]
    column_width=board_width/9
    #get the number of arrow that should be visible
    col = (x/column_width).floor-1
    if col >= 0 && col < 7 && @imageArray[0][col].file == "resources/piece_empty.png"
      @col_selected = col
    end
    class_invariant()
  end

  # Resets the board images to the empty pieces
  def reset_board_images()
    class_invariant()
    @imageArray.each_index { |row|
      @imageArray[0].each_index { |col|
        @imageArray[row][col].set("resources/piece_empty.png")
      }
    }
    class_invariant()
  end

  # Shows a dialog with the winning player
  def show_win(winner)
    show_win_preconditions(winner)
    show_string = winner.to_s + " wins!"
    @win_dialog_label.text = show_string
    @win_dialog.show
    show_win_postconditions()
  end

  def hide_win_dialog()
    class_invariant()
    @win_dialog.hide_on_delete()
    @win_dialog.hide()
    class_invariant()
  end

  # Shows a dialog indicating that it is a tie
  def show_tie()
    class_invariant()
    @win_dialog_label.text = "Draw!"
    @win_dialog.show
    class_invariant()
  end

  # Hides all labels and images depicting the players.
  def hide_all_player_labels_and_images
    class_invariant()
    @player_images.each { |image|
      image.hide()
    }
    @player_labels.each { |label|
      label.hide()
    }
    class_invariant()
  end

  # Updates the game board from the given state object
  def update(grid, active_player)
    #update_preconditions(state)
    grid.each_with_index { |row_obj, row|
      row_obj.each_with_index { |e, col|
        if e != ""
          resource = "resources/piece_" + e.to_s + ".png"
          if @imageArray[row][col].file != resource && @imageArray[row][col].file == "resources/piece_empty.png"
            @imageArray[row][col].set(resource)
          end
        end
      }
    }
    #updates active player
    update_player_labels(active_player)
    update_postconditions()
  end

  # Initializes the board with the given players (hash of name->token value)
  def initialize_players(players)
    initialize_players_preconditions(players)
    @players = players
    update_player_labels(0)
    initialize_players_postconditions()
  end

  # Updates the player labels to reflect that the given active_player is highlighted
  def update_player_labels(active_player)
    update_player_labels_preconditions(active_player)
    hide_all_player_labels_and_images()
    @players.keys.each_with_index { |player, index|
      @player_images[index].set("resources/" + player + ".png")
      @player_images[index].show()
      @player_labels[index].markup = @players[player]
      @player_labels[index].show()
    }
    @player_labels[active_player].markup = "<b>" + @players[@players.keys[active_player]] + "</b>"
    update_player_labels_postconditions
  end

  # Retrieves the player name from the text field. If not given, uses a default name.
  def get_player_name
    pre_get_player_name()
    if @player_name.text == ""
      result = "PLAYER1"
    else
      result = @player_name.text
    end
    post_get_player_name(result)
    return result
  end

  # Retrieves the game name from the text field. If not given, uses a default name.
  def get_game_name
    pre_get_game_name()
    if @game_name.text == ""
      result = "Game " + Time.now.to_s
    else
      result = @game_name.text
    end
    post_get_game_name(result)
    return result
  end

  # Returns the user's chosen difficulty setting
  def get_difficulty
    pre_get_difficulty()
    difficulty = 0
    if @easy.active?
      difficulty = 0.80
    elsif @medium.active?
      difficulty = 0.40
    end
    post_get_difficulty(difficulty)
    return difficulty
  end

  # Returns the user selected mode
  def get_mode
    pre_get_mode()
    if @otto_radiobutton.active?
      game_type = "otto"
    else
      game_type = "connect4"
    end
    post_get_mode(game_type)
    return game_type
  end

  # Returns the selected game ID (if there is one)
  def get_selected_game
    class_invariant()
    selected = @games_list.selection.selected
    if selected != nil
      return selected.get_value(1)
    end
    class_invariant()
  end

  # Returns the IP address text field value
  def get_ip
    return @ip_address.text
  end

  # Returns the port text field value
  def get_port
    return @port.text.to_i
  end

  private

  # Gets all widgets into useful class variables
  def get_all_widgets
    #Get all miscellaneous widgets
    @statistics_dialog=@builder.get_object("stat_dialog")
    @statistics_table=@builder.get_object("treeview2")
    @port=@builder.get_object("entry9")
    @game_name=@builder.get_object("entry34")
    @games_list=@builder.get_object("treeview1")
    @player_name=@builder.get_object("entry1")
    @ip_address=@builder.get_object("entry2")
    @error_dialog=@builder.get_object("errordialog")
    @error_dialog_exception=@builder.get_object("errdialog_exception")
    @board=@builder.get_object("board")
    @win_dialog=@builder.get_object("win_dialog")
    @win_dialog_label=@builder.get_object("winner_label")
    @eventbox=@builder.get_object("eventbox1")
    @otto_radiobutton=@builder.get_object("radiobutton2")
    @humans=@builder.get_object("spinbutton1")
    @computers=@builder.get_object("spinbutton2")
    @easy=@builder.get_object("radiobutton3")
    @medium=@builder.get_object("radiobutton4")
    @help=@builder.get_object("aboutdialog1")
    @start_btn = @builder.get_object("start_button")
    @join_btn = @builder.get_object("join_button")

    #Get all arrows
    @arrows = []
    (1..7).each { |col|
      @arrows << @builder.get_object("arrow" + col.to_s)
    }
    #Get all player labels and images
    @player_labels = []
    @player_images = []
    (1..4).each { |player|
      @player_labels << @builder.get_object("p"+player.to_s+"_label")
      @player_images << @builder.get_object("p"+player.to_s+"_image")
    }
    #Get all images
    @imageArray  = Array.new(6) { Array.new(7) }
    count = 0
    @imageArray.each_index  { |row|
      @imageArray[0].each_index { |col|
        imageString = "img" + count.to_s()
        @imageArray[row][col] = @builder.get_object(imageString)
        count = count + 1
      }
    }
    #Set event handler for eventbox
    @eventbox.set_events(Gdk::Event::POINTER_MOTION_MASK)
  end

  def column_full?(column)
    value = @imageArray[0][column].file
    if value == "resources/piece_empty.png"
      return false
    else
      return true
    end
  end
end