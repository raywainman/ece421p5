require "test/unit"

require_relative "../../contracts/common_contracts"

# Contracts for the MainController class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module MainControllerContracts
  include Test::Unit::Assertions
  include CommonContracts
  
  def pre_initialize(view, local_port)
    # TODO: CHECK THE VIEW METHODS
    assert view.respond_to?("humans"), "view must respond to humans"
    assert view.respond_to?("computers"), "view must respond to computers"
    assert view.respond_to?("show_error_dialog"), "view must respond to show_error_dialog"
    assert view.respond_to?("get_difficulty"), "view must respond to get_difficulty"
    assert view.respond_to?("get_mode"), "view must respond to get_mode"
    assert view.respond_to?("get_player_name"), "view must respond to get_player_name"
    assert view.respond_to?("get_game_name"), "view must respond to get_game_name"
    assert view.respond_to?("get_selected_game"), "view must respond to get_selected_game"
    assert view.respond_to?("set_game_list"), "view must respond to set_game_list"
    assert view.respond_to?("get_ip"), "view must respond to get_ip"
    assert view.respond_to?("get_port"), "view must respond to get_port"
    assert view.respond_to?("initialize_players"), "view must respond to initialize_players"
    assert view.respond_to?("reset_board_images"), "view must respond to reset_board_images"
    assert view.respond_to?("show_board"), "view must respond to show_board"
    check_port(local_port)
  end

  def post_initialize()
    assert @view != nil, "view cannot be nil"
    check_port(@local_port)
    assert @winner == -1, "winner is not initialized correctly"
    check_ip(@local_ip)
  end

  def initialize_preconditions(view)
    # TODO: FIX THIS CONTRACT
    #assert view.respond_to?("humans"), "view must respond to humans()"
    #assert view.respond_to?("computers"), "view must respond to computers()"
    #assert view.respond_to?("otto_radiobutton"), "view must respond to otto_radiobutton()"
    #assert view.respond_to?("connect4_radiobutton"), "view must respond to connect4_radiobutton()"
    #assert view.respond_to?("easy"), "view must respond to easy()"
    #assert view.respond_to?("medium"), "view must respond to medium()"
    #assert view.respond_to?("reset_board_images"), "view must respond to reset_board_images"
    #assert view.respond_to?("show_board"), "view must respond to show_board"
    #assert view.respond_to?("col_selected"), "view must respond to col_selected"
    #assert view.respond_to?("set_column_selected"), "view must respond to set_column_selected"
    #assert view.respond_to?("show_arrow"), "view must respond to show_arrow"
    #assert view.respond_to?("win_dialog"), "view must respond to win_dialog"
  end

  def initialize_postconditions()
    # TODO: FIX THIS CONTRACT
    #assert @view != nil, "view must not be nil"
  end

  def class_invariant()
    assert @view != nil, "view is not initialized correctly"
    assert @local_port != 0, "local_port is not initialized correctly"
    assert @winner == -1, "winner is not initialized correctly"
    check_ip(@local_ip)
  end
end