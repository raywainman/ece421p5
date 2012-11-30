require_relative "./contracts/state_contracts"

# Game state object. This object contains all pertinent information needed
# by the clients to update their interfaces to reflect the latest game values.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class State
  include StateContracts

  attr_reader :grid, :active_player
  def initialize(grid, active_player)
    initialize_preconditions(grid, active_player)
    @grid = grid
    @active_player = active_player
    initialize_postconditions()
  end
end