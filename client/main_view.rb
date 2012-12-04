require "rubygems"
require "gtk2"

require_relative "./main_controller"
require_relative "./contracts/main_view_contracts"

# User interface for the connect4/otto game

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class MainView
  include MainViewContracts

  # Expose form widgets and other important components
  attr_reader :humans, :computers, :col_selected, :statistics_table
  # Initializes GUI via .glade file and gets all the widgets
  def initialize()
    #initialize_preconditions()
    Gtk.init
    @builder = Gtk::Builder::new
    @builder.add_from_file("./GUI.glade")
    get_all_widgets()
    @col_selected=0
    #initialize_postconditions()

    @ip_address.text = "Ray-PC"
    @port.text = "50500"
  end

  # Sets the controller for this view and attaches all signal handlers
  def set_controller(controller)
    #set_controller_preconditions(controller)
    @controller = controller
    @builder.connect_signals{ |handler| controller.method(handler) }
    #set_controller_postconditions()
  end

  # Shows the main application window (the main menu)
  def show
    @builder.get_object("mainMenu").show()
    Gtk.main()
  end

  # Shows the board and assigns it the passed in string value as a title
  def show_board()
    #show_board_preconditions(string)
    @board.hide_on_delete()
    @board.show()
    show_board_postconditions
  end

  def hide_board()
    @board.hide()
  end

  def show_error_dialog(exception)
    @error_dialog_exception.text = exception
    @error_dialog.show()
  end

  def show_statistics_dialog()
    @statistics_dialog.hide_on_delete()
    @statistics_dialog.show()
  end

  def hide_statistics_dialog()
    @statistics_dialog.hide()
  end

  def show_help()
    @help.hide_on_delete()
    @help.show()
  end
  
  def hide_help()
    @help.hide()
  end

  #+++++++++++++++++++++Helper functions, not signal handlers!++++++++++++++++++++
  # Shows the corresponding arrow based on the value stored in the class variable
  # @col_selected
  def show_arrow()
    #hide all arrows first
    @arrows.each { |arrow|
      arrow.hide
    }
    #Then show the one stored
    @arrows[@col_selected].show
  end

  # Method that modifies the global variable of the column selected
  # when passing the X coordinate. Called every time the mouse moves
  def set_column_selected(x)
    #get the window width
    board_width=@board.size[0]
    column_width=board_width/9
    #get the number of arrow that should be visible
    col = (x/column_width).floor-1
    if col >= 0 && col < 7 && @imageArray[0][col].file == "resources/piece_empty.png"
      @col_selected = col
    end
  end

  # Resets the board images to the empty pieces
  def reset_board_images()
    @imageArray.each_index { |row|
      @imageArray[0].each_index { |col|
        @imageArray[row][col].set("resources/piece_empty.png")
      }
    }
  end

  # Shows a dialog with the winning player
  def show_win(winner)
    #show_win_preconditions(winner)
    show_string = winner.to_s + " wins!"
    @win_dialog_label.text = show_string
    @win_dialog.show
    @win_dialog.hide_on_delete()
    show_win_postconditions()
  end

  def hide_win_dialog()
    @win_dialog.hide()
  end

  # Shows a dialog indicating that it is a tie
  def show_tie()
    @win_dialog_label.text = "Draw!"
    @win_dialog.show
  end

  # Hides all labels and images depicting the players.
  def hide_all_player_labels_and_images
    @player_images.each { |image|
      image.hide()
    }
    @player_labels.each { |label|
      label.hide()
    }
  end

  # Updates the game board from the given state object
  def update(grid, active_player)
    #update_preconditions(state)
    grid.each_with_index { |row_obj, row|
      row_obj.each_with_index { |e, col|
        if e != nil
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

  def get_player_name
    if @player_name.text == ""
      return "PLAYER1"
    else
      return @player_name.text
    end
  end

  def get_game_name
    if @game_name.text == ""
      return "Game " + Time.now.to_s
    else
      return @game_name.text
    end
  end

  def get_difficulty
    difficulty = 0
    if @easy.active?
      difficulty = 0.80
    elsif @medium.active?
      difficulty = 0.40
    end
    return difficulty
  end

  def get_mode
    if @view.otto_radiobutton.active?
      game_type = "otto"
    else
      game_type = "connect4"
    end
    return game_type
  end

  def get_selected_game
    selected = @games_list.selection.selected
    if selected != nil
      return selected.get_value(1)
    end
  end

  def get_ip
    return @ip_address.text
  end

  def get_port
    return @port.text.to_i
  end

  def set_game_list(games)
    @games_list.model.clear
    games.each { |id, name|
      row = @games_list.model.insert(0)
      row.set_value(0, name)
      row.set_value(1, id)
    }
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
    @error_dialog_exception=@builder.get_object("errordialog_exception")
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
end