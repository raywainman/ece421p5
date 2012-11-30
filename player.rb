require_relative "./contracts/player_contracts"

# Abstract Player class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class Player
  include PlayerContracts

  attr_reader :token, :winning_token
  
  # Computes a move to be played by the player, returns the column number to
  # play
  def do_move(grid)
    raise "Not Implemented"
  end

  # Returns a string description of the type of player
  def description()
    raise "Not Implemented"
  end

  # Sets the token for this particular player
  def set_token(token)
    set_token_preconditions(token)
    @token = token
    set_token_postconditions()
  end

  # Sets the winning token for this particular player
  def set_winning_token(winning_token)
    set_winning_token_preconditions(winning_token)
    @winning_token = winning_token
    set_winning_token_postconditions()
  end
end