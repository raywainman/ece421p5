require "test/unit"

# Contracts for the GameType class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module GameTypeContracts
  include Test::Unit::Assertions
  
  def check_grid(grid)
    assert !grid.nil?, "Grid cannot be null"
    assert grid.respond_to?("[]"), "grid must respond to []"
    assert grid.respond_to?("get_row_length"), "grid must respond to get_row_length"
    assert grid.respond_to?("get_column_length"), "grid must respond to get_column_length"
  end
  
  def check_sentinels(sentinel)
    assert !sentinel.nil?, "sentinel cannot be null"
    assert sentinel.is_a?(String), "sentinel must be a string"
    assert sentinel.respond_to?("empty?")
    assert !sentinel.empty?
  end
  
  def check_matches_result(result)
    assert !result.nil?, "match results cannot be null"
    assert result.is_a?(String), "match must be a string"
  end
  
  def check_token(token)
    assert !token.nil?, "token cannot be null"
    assert token.is_a?(String), "winning token must be a string"
    assert token.respond_to?("empty?")
    assert !token.empty?
  end
  
  def check_token_length(length)
    assert !length.nil?, "token cannot be null"
    assert length.is_a?(Integer), "winning token must be a string"
  end

  def evaluate_win_preconditions(grid, winning_token)
    check_grid(grid)
    check_token(winning_token)
  end

  def evaluate_win_postconditions(result)
    assert(result!=nil)
    assert(result == true || result == false)
  end

  def pre_evaluate_horizontal_win(grid, sentinel, null_sentinel, expected_length)
    check_grid(grid)
    check_sentinels(sentinel)
    check_sentinels(null_sentinel)
    check_token_length(expected_length)
  end

  def post_evaluate_horizontal_win(result)
    check_matches_result(result)
  end

  def pre_evaluate_vertical_win(grid, sentinel, null_sentinel, expected_length)
    check_grid(grid)
    check_sentinels(sentinel)
    check_sentinels(null_sentinel)
    check_token_length(expected_length)
  end

  def post_evaluate_vertical_win(result)
    check_matches_result(result)
  end

  def pre_evaluate_right_diagonal_win(grid, sentinel, null_sentinel, expected_length)
    check_grid(grid)
    check_sentinels(sentinel)
    check_sentinels(null_sentinel)
    check_token_length(expected_length)
  end

  def post_evaluate_right_diagonal_win(result)
    check_matches_result(result)
  end

  def pre_evaluate_left_diagonal_win(grid, sentinel, null_sentinel, expected_length)
    check_grid(grid)
    check_sentinels(sentinel)
    check_sentinels(null_sentinel)
    check_token_length(expected_length)
  end

  def post_evaluate_left_diagonal_win(result)
    check_matches_result(result)
  end
end