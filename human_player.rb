require_relative "./player"
require_relative "./contracts/human_player_contracts"

# Human Player object.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class HumanPlayer < Player
  include HumanPlayerContracts
  
  # Prompts the user to play a move from the command line
  # DEPRECATED when using the GUI
  def do_move(grid)
    do_move_preconditions(grid, other_players)
    class_invariant()
    print "Add to column> "
    result = gets.to_i
    class_invariant()
    do_move_postconditions(result)
    return result
  end

  # Returns a description of the player type
  def description()
    "Player"
  end
end