require_relative "./ai_player"
require_relative "./connect4"
require_relative "./grid"
require_relative "./human_player"
require_relative "./contracts/game_contracts"

# Main game object. All game logic is amalgamated here.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class Game
  include GameContracts
  
  attr_reader :players, :winner, :winner_name, :game_name
  
  # Creates a new instance of the game given a GameType, a list of Player objects
  # and a View object to update
  def initialize(game_type, players, game_name)
    initialize_preconditions(game_type, players, game_name)
    @game_type = game_type
    @players = players
    initialize_players()
    @game_name = game_name
    @grid = Grid.new
    @active_player = 0
    @winner = -1
    @winner_name = ""
    class_invariant()
    initialize_postconditions()
  end

  # Resets the game to the initial state
  def reset()
    reset_preconditions()
    class_invariant()
    @grid.reset()
    @winner = -1
    @winner_name = ""
    @active_player = 0
    @view.reset_board_images
    @view.update(get_state())
    puts "Resetting game"
    class_invariant()
    reset_postconditions()
  end

  # Delegate method to check if the given column is full
  def is_column_full?(column)
    @grid.is_column_full?(column)
  end

  # Constructs a State object from the current game state
  def get_state()
    #get_state_preconditions()
    class_invariant()
    #result = State.new(@grid.grid, @active_player, @winner)
    class_invariant()
    #get_state_postconditions(result)
    return @grid.grid, @active_player
  end

  # Determines if the current board state results in a win for the current
  # active player
  def is_win()
    #is_win_preconditions()
    class_invariant()
    winner = -1
    (0...@players.size).each { |player_index|
      result = @game_type.evaluate_win(@grid, @game_type.winning_token(player_index))
      if result
        winner = player_index
        puts "Player " + (player_index+1).to_s + " has won"
      end
    }
    class_invariant()
    #is_win_postconditions(winner)
    return winner
  end

  # Checks to see if it is the end of the game (via a win or tie) and launches
  # the appropriate action.
  def is_end?
    @winner = is_win()
    if @winner != -1
      @winner_name = @players[@winner].name
      puts "Winner " + winner_name
      return true
    elsif @grid.is_full?
      puts "Tie Game"
      @winner = -2
      return true
    end
    return false
  end

  # Plays a move for the current active player and will play any subsequent AI players
  # (if it is their turn)
  def make_move(player, column)
    puts "player - " + player
    make_move_preconditions(player, column)
    class_invariant()
    if @active_player != get_player_index(player)
      puts "Invalid move"
      return false
    end
    if @winning == -1 || @winning == -2
      puts "Game is over!"
      return false
    end

    puts "Player " + player + " made a move on column " + column.to_s
    @grid.make_move(@game_type.get_player_label(@active_player), column)
    if is_end?
      return true
    end
    @active_player = (@active_player + 1) % @players.size

    # Play AI moves (if there are any)
    while @players[@active_player].is_a?(AIPlayer)
      move = @players[@active_player].do_move(@grid)
      puts @players[@active_player].name + " made a move on column " + move.to_s
      @grid.make_move(@game_type.get_player_label(@active_player), move)
      if is_end?
        return true
      end
      @active_player = (@active_player + 1) % @players.size
    end
    class_invariant()
    make_move_postconditions()
    return true
  end

  def get_player_names()
    players = {}
    @players.each { |player|
      players[player.token] = player.name
    }
    return players
  end

  def collect_statistics()
    stats = {}
    if @winning != -1 && @winning != -2
      stats["WINNER"] = @winner_name
    end
    token_count = {}
    @players.each{ |player|
      if player.is_a?(HumanPlayer)
        token_count[player.name] = @grid.count_tokens(player.token)
      end
    }
    stats["PLAYERS"] = token_count
    return stats
  end
  
  def to_s()
    str = "Game: " + @game_name
    str << ", Players: " + @players.to_s
    str << ", Active Player: " + @active_player.to_s
  end

  private

  # Set the tokens and other player properties
  def initialize_players()
    @players.each_with_index{ |player, index|
      player.set_token(@game_type.get_player_label(index))
      player.set_winning_token(@game_type.winning_token(index))
    }
    @players.each { |player|
      if player.is_a?(AIPlayer)
        other_players = Hash.new
        @players.each { |other_player|
          if other_player != player
            other_players[other_player.token] = other_player.winning_token
          end
        }
        player.set_other_players(other_players)
      end
    }
  end

  def get_player_index(player)
    @players.each_with_index { |player_obj, player_index|
      if player_obj.name == player
        return player_index
      end
    }
  end

end