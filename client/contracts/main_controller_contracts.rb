require "test/unit"

require_relative "../../contracts/common_contracts"

# Contracts for the MainController class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

module MainControllerContracts
  include Test::Unit::Assertions
  include CommonContracts
  def pre_initialize(view, local_port)
    assert view.respond_to?("humans"), "view must respond to humans"
    assert view.respond_to?("computers"), "view must respond to computers"
    assert view.respond_to?("show_error_dialog"), "view must respond to show_error_dialog"
    assert view.respond_to?("get_difficulty"), "view must respond to get_difficulty"
    assert view.respond_to?("get_mode"), "view must respond to get_mode"
    assert view.respond_to?("get_player_name"), "view must respond to get_player_name"
    assert view.respond_to?("get_game_name"), "view must respond to get_game_name"
    assert view.respond_to?("get_selected_game"), "view must respond to get_selected_game"
    assert view.respond_to?("games_list"), "view must respond to games_list"
    assert view.respond_to?("statistics_table"), "view must respond to games_list"
    assert view.respond_to?("get_ip"), "view must respond to get_ip"
    assert view.respond_to?("get_port"), "view must respond to get_port"
    assert view.respond_to?("initialize_players"), "view must respond to initialize_players"
    assert view.respond_to?("reset_board_images"), "view must respond to reset_board_images"
    assert view.respond_to?("show_board"), "view must respond to show_board"
    assert view.respond_to?("col_selected"), "view must respond to col_selected"
    assert view.respond_to?("set_column_selected"), "view must respond to set_column_selected"
    assert view.respond_to?("show_arrow"), "view must respond to show_arrow"
    check_port(local_port)
  end

  def post_initialize()
    assert @view != nil, "view cannot be nil"
    check_port(@local_port)
    assert @winner == -1, "winner is not initialized correctly"
    check_ip(@local_ip)
  end

  def pre_set_win(win)
    if win.is_a?(String)
      assert win.size > 0, "winner must not be empty"
    else
      assert win == 0, "winner must be 0 if there is a tie"
    end
    class_invariant()
  end

  def post_set_win()
    class_invariant()
    assert @winner != -1, "winner cannot be set to -1"
    check_winner(@winner)
  end
  
  def class_invariant()
    assert @view != nil, "view is not initialized correctly"
    assert @local_port != 0, "local_port is not initialized correctly"
    check_winner(@winner)
    check_ip(@local_ip)
  end

  def check_winner(win)
    if win.is_a?(String)
      assert win.size > 0, "winner must not be empty"
    else
      assert win == -1 || win == 0, "winner must be -1 or 0"
    end
  end
end