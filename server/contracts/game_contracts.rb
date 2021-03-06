require "test/unit"

require_relative "../../contracts/common_contracts"

# Contracts for Game object.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

module GameContracts
  include Test::Unit::Assertions
  include CommonContracts
  def initialize_preconditions(game_type, players, game_name)
    assert game_type.is_a?(GameType), "game_type argument must be a GameType object"
    assert players.respond_to?("[]"), "players argument must be a container of players"
    assert players.respond_to?("size"), "players argument must have a size function"
    assert players.size >= game_type.min_players, "not enough players for game mode"
    assert players.size <= game_type.max_players, "too many players for game mode"
    players.each{ |player|
      assert player.is_a?(Player), "players argument must be all Player objects"
    }
    assert game_name.is_a?(String), "game_name must be a string"
  end

  def initialize_postconditions()
    assert @grid  != nil, "grid must not be nil"
    assert @players != nil, "players class element cannot be nil"
    assert @game_type != nil, "game_type class element cannot be nil"
    assert @active_player == 0, "active_player must be first player"
    assert @game_name != nil, "view must not be nil"
    assert @winner == -1, "winner must be set to -1"
    assert @winner_name == "", "winner_name must be set to empty string"
  end

  def reset_preconditions()
    # No preconditions for reset
  end

  def reset_postconditions()
    @grid.each{ |element|
      assert element == "", "grid element must be an empty string to start"
    }
    assert @active_player == 0, "active_player must be first player"
    assert @winner == -1, "winner must be set to -1"
    assert @winner_name == "", "winner_name must be set to empty string"
  end

  def get_state_preconditions()
    # No preconditions
  end

  def get_state_postconditions(grid, active_player)
    check_grid_array(grid)
    check_active_player(active_player)
  end

  def is_win_preconditions()
    # No preconditions
  end

  def is_win_postconditions(result)
    assert result == -1 || (result >= 0 && result < @players.size), "result must be a player value"
  end

  def show_win_preconditions(winner)
    assert winner >= 0, "winner must be a valid player"
    assert winner < @players.size, "winner must be a valid player"
  end

  def show_win_postconditions()
    # No postconditions
  end

  def make_move_preconditions(player, column)
    assert column >= 0, "column not within range"
    assert column < 7, "column not within range"
    player_contained = false
    @players.each { |player_obj|
      if player_obj.name == player
        player_contained = true
      end
    }
    assert player_contained, "invalid player id"
  end

  def make_move_postconditions()
    # No postconditions
  end

  def post_get_player_names(players)
    check_player_hash(players)
  end

  def post_collect_statistics(stats)
    assert stats.respond_to?("keys"), "stats should respond to keys()"
    assert stats.has_key?("PLAYERS"), "stats should at least contain PLAYERS"
  end
  
  def pre_is_single_player?()
    #None
  end
  
  def post_is_single_player?(result)
    assert(result==true || result == false, "invalid result detected")
  end
  
  def is_column_full_preconditions(column)
    assert column >= 0, "column must be within range"
    assert column < 7, "column must be within range"
  end

  def is_column_full_postconditions()
    # No postconditions
  end
  
  def class_invariant()
    assert @grid.is_a?(Grid), "grid must be a Grid object"
    @grid.class_invariant()
    assert @players != nil, "players class element cannot be nil"
    assert @game_type != nil, "game_type class element cannot be nil"
    assert @active_player >= 0, "active_player must be a positive integer"
    assert @active_player < @players.size, "active_player must be an actual player"
    assert @game_name != nil, "game_name must not be nil"
  end
end