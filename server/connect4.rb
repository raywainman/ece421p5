require "singleton"

require_relative "./game_type"
require_relative "./contracts/connect4_contracts"

# Connect4 game object. Defines many properties of the game including winning
# conditions, minimum and maximum players and player labels.
# Singleton class - must be accessed via the Connect4.instance method.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class Connect4 < GameType
  include Singleton
  include Connect4Contracts

  @@labels = ["R", "Y", "G", "B"]

  def self.labels
    return @@labels
  end

  # Returns the label for the given player number
  def get_player_label(player)
    get_player_label_preconditions(player)
    class_invariant()
    result = @@labels[player]
    class_invariant()
    get_player_label_postconditions(result)
    return result
  end

  # Returns the maximum number of players
  def max_players()
    return 4
  end

  # Returns the minimum number of players
  def min_players()
    return 2
  end

  # Returns a textual description of the game
  def game_name()
    return "Connect4"
  end
  
  # Computes the winning token sequence for the given player
  def winning_token(player)
    winning_token_preconditions(player)
    str = ""
    4.times {
      str << get_player_label(player)
    }
    winning_token_postconditions(str)
    return str
  end
end