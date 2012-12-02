require "test/unit"

# Contracts for the HumanPlayer class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module HumanPlayerContracts
  include Test::Unit::Assertions
  def do_move_preconditions(grid)
    assert grid.is_a?(Grid), "invalid grid argument"
  end

  def do_move_postconditions(result)
    assert result >= 0, "move must be a valid column"
    assert result < 7, "move must be a valid column"
  end

  def class_invariant
    assert @token != nil, "token still not set"
    assert @winning_token != nil, "winning token cannot be nil"
  end
end