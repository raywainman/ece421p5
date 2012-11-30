require "test/unit"

# Contracts for Game object.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module GameContracts
  include Test::Unit::Assertions
  def initialize_preconditions(game_type, players, view)
    assert game_type.is_a?(GameType), "game_type argument must be a GameType object"
    assert players.respond_to?("[]"), "players argument must be a container of players"
    assert players.respond_to?("size"), "players argument must have a size function"
    assert players.size >= game_type.min_players, "not enough players for game mode"
    assert players.size <= game_type.max_players, "too many players for game mode"
    players.each{ |player|
      assert player.is_a?(Player), "players argument must be all Player objects"
    }
    assert view.respond_to?("update"), "view must respond to update(state)"
    assert view.respond_to?("initialize_players"), "view must respond to initialize_players()"
    assert view.respond_to?("reset_board_images"), "view must respond to reset_board_images()"
  end

  def initialize_postconditions()
    assert @grid  != nil, "grid must not be nil"
    assert @players != nil, "players class element cannot be nil"
    assert @game_type != nil, "game_type class element cannot be nil"
    assert @active_player == 0, "active_player must be first player"
    assert @view != nil, "view must not be nil"
  end

  def reset_preconditions()
    # No preconditions for reset
  end

  def reset_postconditions()
    @grid.each{ |element|
      assert element == nil, "grid element must be nil to start"
    }
    assert @active_player == 0, "active_player must be first player"
  end

  def get_state_preconditions()
    # No preconditions
  end

  def get_state_postconditions(result)
    assert result.is_a?(State), "state must be a State object"
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

  def make_move_preconditions(column)
    assert column >= 0, "column not within range"
    assert column < 7, "column not within range"
  end

  def make_move_postconditions()
    # No postconditions
  end

  def class_invariant()
    assert @grid.is_a?(Grid), "grid must be a Grid object"
    @grid.class_invariant()
    assert @players != nil, "players class element cannot be nil"
    assert @game_type != nil, "game_type class element cannot be nil"
    assert @active_player >= 0, "active_player must be a positive integer"
    assert @active_player < @players.size, "active_player must be an actual player"
    assert @view != nil, "view must not be nil"
  end
end