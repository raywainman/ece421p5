require "test/unit"

require_relative "../../contracts/common_contracts"

# Contracts for the MainView class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

module MainViewContracts
  include Test::Unit::Assertions
  include CommonContracts
  def initialize_preconditions()
    # No preconditions
  end

  def initialize_postconditions()
    assert @builder != nil, "builder cannot be nil"
    assert @col_selected == 0, "selected column must be set to 0"
    assert @statistics_dialog != nil, "statistics dialog must not be nil"
    assert @statistics_table != nil, "satitistics table must not be nil"
    assert @port != nil, "port must not be nil"
    assert @game_name != nil, "game_name must not be nil"
    assert @games_list != nil, "games list must not be nil"
    assert @player_name != nil, "player_name must not be nil"
    assert @ip_address != nil, "ip_address must not be nil"
    assert @error_dialog != nil, "error_dialog must not be nil"
    assert @error_dialog_exception != nil, "error_dialog_exception must not be nil"
    assert @board != nil, "board must not be mil"
    assert @win_dialog != nil, "win_dialog cannot be nil"
    assert @win_dialog_label != nil, "win_dialog_label cannot be nil"
    assert @eventbox != nil, "eventbox cannot be nil"
    assert @otto_radiobutton != nil, "otto_radiobutton cannot be nil"
    assert @humans != nil, "humans cannot be nil"
    assert @computers != nil, "computers cannot be nil"
    assert @easy != nil, "easy cannot be nil"
    assert @medium != nil, "medium cannot be nil"
    assert @help != nil, "help cannot be nil"
    assert @start_btn != nil, "start_btn cannot be nil"
    assert @join_btn != nil, "join_btn cannot be nil"
    assert @imageArray != nil, "imageArray cannot be nil"
    assert @arrows != nil, "arrows cannot be nil"
    assert @arrows.size == 7, "arrows must contain 7 elements"
    assert @player_labels != nil, "player_labels cannot be nil"
    assert @player_labels.size == 4, "player_labels must contain 4 elements"
    assert @player_images != nil, "player_images cannot be nil"
    assert @player_images.size == 4, "player_images must contain 4 elements"
  end

  def set_controller_preconditions(controller)
    assert controller.respond_to?("set_win"), "controller must respond to set_win"
    assert controller.respond_to?("gtk_main_quit"), "controller must respond to gtk_main_quit"
    assert controller.respond_to?("on_players_changed"), "controller must respond to on_players_changed"
    assert controller.respond_to?("on_mode_changed"), "controller must respond to on_mode_changed"
    assert controller.respond_to?("on_start_clicked"), "controller must respond to on_start_clicked"
    assert controller.respond_to?("on_join_clicked"), "controller must respond to on_join_clicked"
    assert controller.respond_to?("on_refresh_clicked"), "controller must respond to on_refresh_clicked"
    assert controller.respond_to?("on_statistics_clicked"), "controller must respond to on_statistics_clicked"
    assert controller.respond_to?("on_statistics_close"), "controller must respond to on_statistics_closed"
    assert controller.respond_to?("on_help_clicked"), "controller must respond to on_help_clicked"
    assert controller.respond_to?("on_help_close"), "controller must respond to on_help_close"
    assert controller.respond_to?("on_column_clicked"), "controller must respond to on_column_clicked"
    assert controller.respond_to?("on_column_hover"), "controller must respond to on_column_hover"
    assert controller.respond_to?("on_board_close"), "controller must respond to on_board_close"
    assert controller.respond_to?("on_win_close"), "controller must respond to on_win_close"
    class_invariant()
  end

  def set_controller_postconditions()
    class_invariant()
    assert @controller != nil, "controller cannot be nil"
  end

  def show_win_preconditions(string)
    assert string != nil, "winner name cannot be nil"
    assert string.is_a?(String), "winner name must be a string"
    assert string.size > 0, "winner name must not be empty"
    class_invariant()
  end

  def show_win_postconditions()
    class_invariant()
    # No postconditions
  end

  def update_preconditions(grid, active_player)
    check_grid_array(grid)
    check_active_player(active_player)
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

  def pre_get_player_name
    # No preconditions
    class_invariant()
  end

  def post_get_player_name(result)
    class_invariant()
    check_name(result)
  end

  def pre_get_game_name
    # No preconditions
    class_invariant()
  end

  def post_get_game_name(result)
    class_invariant()
    check_name(result)
  end

  def pre_get_difficulty
    # No preconditions
    class_invariant()
  end

  def post_get_difficulty(result)
    class_invariant()
    assert result >= 0 && result <= 1, "difficulty must be between 0-1"
  end

  def pre_get_mode
    # No preconditions
    class_invariant()
  end

  def post_get_mode(result)
    class_invariant()
    assert result == "connect4" || result == "otto", "invalid mode"
  end

  def update_player_labels_preconditions(active_player)
    assert active_player >= 0, "active_player must be a positive integer"
    assert active_player < @players.size, "active_player must be within range"
  end

  def update_player_labels_postconditions()
    # No postconditions
  end

  def class_invariant()
    assert @col_selected >= 0 && @col_selected < 7, "col_selected in invalid range"
    assert @builder != nil, "builder must not be nil"
  end
end