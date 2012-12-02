require "test/unit"

# Contracts for the MainView class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module MainViewContracts
  include Test::Unit::Assertions
  def initialize_preconditions()
    # No preconditions
  end

  def initialize_postconditions()
    assert @imageArray != nil, "imageArray cannot be nil"
    assert @win_dialog != nil, "win_dialog cannot be nil"
    assert @win_dialog_label != nil, "win_dialog_label cannot be nil"
    assert @eventbox != nil, "eventbox cannot be nil"
    assert @connect4_radiobutton != nil, "connect4_radiobutton cannot be nil"
    assert @otto_radiobutton != nil, "otto_radiobutton cannot be nil"
    assert @humans != nil, "humans cannot be nil"
    assert @computers != nil, "computers cannot be nil"
    assert @easy != nil, "easy cannot be nil"
    assert @medium != nil, "medium cannot be nil"
    assert @help != nil, "help cannot be nil"
    assert @arrows != nil, "arrows cannot be nil"
    assert @arrows.size == 7, "arrows must contain 7 elements"
    assert @player_labels != nil, "player_labels cannot be nil"
    assert @player_labels.size == 4, "player_labels must contain 4 elements"
    assert @player_images != nil, "player_images cannot be nil"
    assert @player_images.size == 4, "player_images must contain 4 elements"
  end

  def set_controller_preconditions(controller)
    assert controller.respond_to?("on_win_dialog_delete_event"), "controller must respond to on_win_dialog_delete_event"
    assert controller.respond_to?("on_return_to_main_button_clicked"), "controller must respond to on_return_to_main_button_clicked"
    assert controller.respond_to?("on_playagain_clicked"), "controller must respond to on_playagain_clicked"
    assert controller.respond_to?("gtk_main_quit"), "controller must respond to gtk_main_quit"
    assert controller.respond_to?("on_start_clicked"), "controller must respond to on_start_clicked"
    assert controller.respond_to?("on_help_clicked"), "controller must respond to on_help_clicked"
    assert controller.respond_to?("on_computers_changed"), "controller must respond to on_computers_changed"
    assert controller.respond_to?("on_humans_changed"), "controller must respond to on_humans_changed"
    assert controller.respond_to?("on_mode_changed"), "controller must respond to on_mode_changed"
    assert controller.respond_to?("on_board_delete_event"), "controller must respond to on_board_delete_event"
    assert controller.respond_to?("on_eventbox1_button_release_event"), "controller must respond to on_eventbox1_button_release_event"
    assert controller.respond_to?("on_eventbox1_motion_notify_event"), "controller must respond to on_eventbox1_motion_notify_event"
    assert controller.respond_to?("on_delete_help"), "controller must respond to on_delete_help"
    assert controller.respond_to?("on_help_close"), "controller must respond to on_help_close"
  end

  def set_controller_postconditions()
    assert @controller != nil, "controller cannot be nil"
  end

  def show_board_preconditions(string)
    assert string != nil, "title cannot be nil"
    assert string.is_a?(String), "title must be a string"
  end

  def show_board_postconditions()
    # No postconditions
  end

  def show_win_preconditions(string)
    assert string != nil, "winner name cannot be nil"
    assert string.is_a?(String), "winner name must be a string"
  end

  def show_win_postconditions()
    # No postconditions
  end

  def update_preconditions(state)
    assert state.respond_to?("grid"), "state object must respond to grid"
    assert state.respond_to?("active_player"), "state object must respond to active_player"
  end

  def update_postconditions()
    # No postconditions
  end

  def initialize_players_preconditions(players)
    assert players.size > 1, "there should be at least 2 players"
    assert players.respond_to?("keys"), "players must respond to keys"
    players.keys.each { |token|
      assert token.size == 1, "token should be of length 1"
      assert players[token] != nil, "player name should be included in hash"
    }
  end

  def initialize_players_postconditions()
    assert @players != nil, "players should not be nil"
  end

  def update_player_labels_preconditions(active_player)
    assert active_player >= 0, "active_player must be a positive integer"
    assert active_player < @players.size, "active_player must be within range"
  end

  def update_player_labels_postconditions()
    # No postconditions
  end
end