require "test/unit"

require_relative "../../contracts/common_contracts"

# Contracts for the Client class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

module ClientContracts
  include Test::Unit::Assertions
  include CommonContracts
  def pre_initialize(port)
    check_port(port)
  end

  def post_initialize()
    assert @view.is_a?(MainView), "view should be a MainView object"
    assert @controller.is_a?(MainController), "controller should be a MainController object"
  end

  def pre_initialize_players(players)
    class_invariant()
    players.each_pair { |key, value|
      assert key.is_a?(String), "key should be a token value"
      assert key.size == 1, "key should be a token value"
      assert value.is_a?(String), "value should be a player name"
    }
  end

  def post_initialize_players()
    class_invariant()
    # No postconditions
  end

  def pre_update(grid, active_player)
    check_grid_array(grid)
    check_active_player(active_player)
    class_invariant()
  end

  def post_update()
    class_invariant()
    # No postconditions
  end

  def pre_win(winner)
    assert winner.is_a?(String), "winner name should be a string"
    assert winner.size > 0, "winner string should not be empty"
    class_invariant()
  end

  def post_win()
    class_invariant()
    # No postconditions
  end

  def pre_tie()
    # No preconditions
    class_invariant()
  end

  def post_tie()
    class_invariant()
    # No postconditions
  end

  def class_invariant()
    assert @view != nil, "view should not be nil"
    assert @controller != nil, "controller should not be nil"
  end
end