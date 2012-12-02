require "test/unit"

# Contracts for the MainController class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module MainControllerContracts
  include Test::Unit::Assertions
  def initialize_preconditions(view)
    assert view.respond_to?("humans"), "view must respond to humans()"
    assert view.respond_to?("computers"), "view must respond to computers()"
    assert view.respond_to?("otto_radiobutton"), "view must respond to otto_radiobutton()"
    assert view.respond_to?("connect4_radiobutton"), "view must respond to connect4_radiobutton()"
    assert view.respond_to?("easy"), "view must respond to easy()"
    assert view.respond_to?("medium"), "view must respond to medium()"
    assert view.respond_to?("reset_board_images"), "view must respond to reset_board_images"
    assert view.respond_to?("show_board"), "view must respond to show_board"
    assert view.respond_to?("col_selected"), "view must respond to col_selected"
    assert view.respond_to?("set_column_selected"), "view must respond to set_column_selected"
    assert view.respond_to?("show_arrow"), "view must respond to show_arrow"
    assert view.respond_to?("win_dialog"), "view must respond to win_dialog"
  end

  def initialize_postconditions()
    assert @view != nil, "view must not be nil"
  end

  def class_invariant()
    assert @game != nil, "game must not be nil"
    assert @view != nil, "view must not be nil"
  end
end