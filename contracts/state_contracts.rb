require "test/unit"

# Contracts for the State class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module StateContracts
  include Test::Unit::Assertions
  def initialize_preconditions(grid, active_player)
    assert grid.is_a?(Grid), "invalid grid"
    assert active_player >= 0, "invalid active player"
    assert active_player < 4, "invalid active player"
  end
  
  def initialize_postconditions()
    assert @grid != nil, "grid must not be nil"
    assert @active_player != nil, "active_player must not be nil"
  end
end