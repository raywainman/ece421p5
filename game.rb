require_relative "./ai_player"
require_relative "./connect4"
require_relative "./grid"
require_relative "./human_player"
require_relative "./state"
require_relative "./contracts/game_contracts"

# Main game object. All game logic is amalgamated here.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class Game
  include GameContracts
  # Creates a new instance of the game given a GameType, a list of Player objects
  # and a View object to update
  def initialize(game_type, players, view)
    initialize_preconditions(game_type, players, view)
    @game_type = game_type
    @players = players
    # Set the tokens and other player properties
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
    @grid = Grid.new
    @active_player = 0
    @view = view
    player_names = {}
    (0...@players.size).each { |player_index|
      player_name =  @players[player_index].description + " " + (player_index+1).to_s
      player_names[@players[player_index].token] = player_name
    }
    @view.initialize_players(player_names)
    class_invariant()
    initialize_postconditions()
  end

  # Resets the game to the initial state
  def reset()
    reset_preconditions()
    class_invariant()
    @grid.reset()
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
    get_state_preconditions()
    class_invariant()
    result = State.new(@grid, (@active_player + 1) % @players.size)
    class_invariant()
    get_state_postconditions(result)
    return result
  end

  # Determines if the current board state results in a win for the current
  # active player
  def is_win()
    is_win_preconditions()
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
    is_win_postconditions(winner)
    return winner
  end

  # Calls the view to alert the user that a win has occurred for the current player
  def show_win(winner)
    show_win_preconditions(winner)
    class_invariant()
    string = @players[winner].description + " " + (winner + 1).to_s
    @view.show_win(string)
    class_invariant()
    show_win_postconditions()
  end

  # Checks to see if it is the end of the game (via a win or tie) and launches
  # the appropriate action.
  def is_end?
    winner = is_win()
    if winner != -1
      show_win(winner)
      return true
    elsif @grid.is_full?
      puts "Tie Game"
      @view.show_tie()
      return true
    end
    return false
  end

  # Plays a move for the current active player and will play any subsequent AI players
  # (if it is their turn)
  def make_move(column)
    make_move_preconditions(column)
    class_invariant()
    puts "Player " + (@active_player+1).to_s + " made a move on column " + column.to_s
    @grid.make_move(@game_type.get_player_label(@active_player), column)
    @view.update(get_state())
    if is_end?
      return
    end
    @active_player = (@active_player + 1) % @players.size

    # Play AI moves (if there are any)
    while @players[@active_player].is_a?(AIPlayer)
      move = @players[@active_player].do_move(@grid)
      puts "AI " + (@active_player+1).to_s + " made a move on column " + move.to_s
      @grid.make_move(@game_type.get_player_label(@active_player), @players[@active_player].do_move(@grid))
      @view.update(get_state())
      if is_end?
        return
      end
      @active_player = (@active_player + 1) % @players.size
    end
    class_invariant()
    make_move_postconditions()
  end
end
