require "test/unit"

# Contracts for the AIPlayer class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module AIPlayerContracts
  include Test::Unit::Assertions
  def initialize_preconditions(difficulty)
    assert difficulty >= 0, "difficulty must be a number between 0 and 1"
    assert difficulty <= 1, "difficulty must be a number between 0 and 1"
  end

  def initialize_postconditions()
    assert @difficulty >= 0, "difficulty must be a number between 0 and 1"
    assert @difficulty <= 1, "difficulty must be a number between 0 and 1"
  end

  def set_other_players_preconditions(other_players)
    assert other_players.is_a?(Hash), "other players must be hash"
    assert other_players.size <= 4, "other_players must be less than size 4"
    assert(other_players!=nil, "opponent data cannot be nil")
    assert(other_players.respond_to?("keys"))
    assert(other_players.respond_to?("[]"))

    data = other_players.keys
    assert(data!=nil, "oppenent data cannot be empty")
    assert(data.respond_to?("each_with_index"), "key result must respond to each_with_index")
    data.each_with_index { |token, index|
      assert(token!=nil, "opponent token cannot be nil")
      assert(token.is_a?(String), "Token must be a string")
    }
  end

  def set_other_players_postconditions()
    assert @other_players != nil, "other_players must not be nil"
  end

  def do_move_preconditions(grid)
    assert @other_players != nil, "other_players must not be nil"
    assert grid.is_a?(Grid), "invalid grid argument"
  end

  def do_move_postconditions(result)
    assert result >= 0, "move must be a valid column"
    assert result < 7, "move must be a valid column"
  end

  def check_grid(grid)
    assert(grid!=nil, "Provided grid cannot be nil")
    assert(grid.respond_to?("[]"), "grid must respond to []")
    assert(grid.respond_to?("each"), "grid must respond to each")
    assert(grid.respond_to?("each_with_index"), "grid must respond to each_with_index")
    assert(grid.respond_to?("column"), "grid must respond to column")
    assert(grid.respond_to?("row"), "grid must respond to row")
    assert(grid.respond_to?("is_column_full?"), "grid must respond to is_column_full?")
    assert(grid.respond_to?("get_row_length"), "grid must respond to get_row_length")
    assert(grid.respond_to?("get_column_length"), "grid must respond to get_column_length")
  end

  def check_column_result(result, grid)
    col = grid.get_column_length()
    assert(result!=nil, "result cannot be nil for a random move")
    assert((result >= 0 and result < col), "invalid result detected")
  end

  def pre_do_rand_move(grid)
    check_grid(grid)
  end

  def pre_strategic_move(grid)
    check_grid(grid)
  end

  def post_strategic_move(result, grid)
    check_column_result(result, grid)
    assert(!grid.is_column_full?(result), "invalid result detected: " + result.to_s)
  end

  def post_do_rand_move(result, grid)
    check_column_result(result, grid)
  end

  def check_rowindicator(rowindicator)
    assert(rowindicator!=nil, "row indicator cannot be nil")
    assert(rowindicator.respond_to?("[]"), "row indicator must respond to []")
    assert(rowindicator.respond_to?("each"), "row indicator must respond to each")
    rowindicator.each(){|i|
      assert(i!=nil, "Row indicator elements cannot be nil")
      assert(i.is_a?(Integer), "Row indicator values must be an integer")
    }
  end

  def check_score(score, grid, player_index)
    assert(score!=nil, "Score cannot be nil")
    assert(score.respond_to?("[]"), "score must respond to []")
    assert(score.respond_to?("each"), "score must respond to each")
    assert(score.respond_to?("length"), "score must respond to length")
    assert(score.length > player_index, "score must size invalid")

    score.each(){|child|

      assert(child!=nil, "Score cannot be nil")
      assert(child.respond_to?("[]"), "score must respond to []")
      assert(child.respond_to?("length"), "score must respond to length")
      assert(child.length == grid.get_column_length(), "Score sub collections must be the size of the grid")
    }

  end

  def pre_generic_check(player_index, player_token, win_seq, grid, rowindicator, score)
    assert(player_index!=nil, "Player index cannot be nil")
    assert(player_token!=nil, "player token cannot be nil")
    assert(win_seq!=nil, "winning sequence cannot be nil")
    check_grid(grid)
    check_rowindicator(rowindicator)
    check_score(score, grid, player_index)

    assert(player_index.is_a?(Integer), "Player index must be an integer")
    assert(player_token.is_a?(String), "Player token must be a string")
    assert(win_seq.is_a?(String), "winning sequence must be a string")
  end

  def pre_horizscore(player_index, player_token, win_seq, grid, rowindicator, score)
    pre_generic_check(player_index, player_token, win_seq, grid, rowindicator, score)
  end

  def post_horizscore(player_index, player_token, win_seq, grid, rowindicator, score)
    check_score(score, grid, player_index)
  end

  def pre_vertscore(player_index,player_token, win_seq, grid, rowindicator, score)
    pre_generic_check(player_index, player_token, win_seq, grid, rowindicator, score)
  end

  def post_vertscore(player_index,player_token, win_seq, grid, rowindicator, score)
    check_score(score, grid, player_index)
  end

  def pre_leftdiagscore(player_index,player_token, win_seq, grid, rowindicator, score)
    pre_generic_check(player_index, player_token, win_seq, grid, rowindicator, score)
  end

  def post_leftdiagscore(player_index,player_token, win_seq, grid, rowindicator, score)
    check_score(score, grid, player_index)
  end

  def pre_rightdiagscore(player_index,player_token, win_seq, grid, rowindicator, score)
    pre_generic_check(player_index, player_token, win_seq, grid, rowindicator, score)
  end

  def post_rightdiagscore(player_index,player_token, win_seq, grid, rowindicator, score)
    check_score(score, grid, player_index)
  end

  def pre_append_unless_nil(result_string, grid, checkrow, checkcol)
    assert(result_string!=nil, "Result string cannot be nil")
    assert(result_string.is_a?(String))
    check_grid(grid)
    check_column_result(checkrow, grid)
    check_column_result(checkcol, grid)
  end

  def post_append_unless_nil(result, result_string, grid, checkrow, checkcol)
    assert(!result_string.empty?, "result string cannot be empty")
    assert(result!=nil)
    assert(result === true || result === false, "result must be a boolean value")
  end

  def pre_prepend_unless_nil(result_string, grid, checkrow, checkcol)
    pre_append_unless_nil(result_string, grid, checkrow, checkcol)
  end

  def post_prepend_unless_nil(result, result_string, grid, checkrow, checkcol)
    post_append_unless_nil(result, result_string, grid, checkrow, checkcol)
  end

  def pre_build_value_hash(expected_sequence)
    assert(expected_sequence!=nil, "provided sequence cannot be nil")
    assert(expected_sequence.is_a?(String), "sequence must be a string")
  end

  def post_build_value_hash(result_hash)
    assert(result_hash!=nil, "result must be a hash")
    assert(result_hash.is_a?(Hash), "result must be a hash")
  end

  def pre_process_score(expected_seq, seq, token, player_index, score, column)
    assert(expected_seq!=nil, "expected sequence cannot be nil")
    assert(expected_seq.is_a?(String), "sequence must be a string")

    assert(seq!=nil, "provided sequence cannot be nil")
    assert(seq.is_a?(String), "sequence must be a string")

    assert(token!=nil, "provided token cannot be nil")
    assert(token.is_a?(String), "token must be a string")

    assert(player_index!=nil, "player index cannot be nil")
    assert(player_index.is_a?(Integer), "player index must be a integer")

    assert(column!=nil, "provided column cannot be nil")
    assert(column.is_a?(Integer), "column must be a integer")

    assert(score!=nil, "score cannot be nil")
  end

  def post_process_score(expected_seq, seq, token, player_index, score, column)
    #None
  end

  def pre_buildRowIndicator(grid)
    check_grid(grid)
  end

  def post_buildRowIndicator(grid, row_indicator)
    check_rowindicator(row_indicator)
  end

  def class_invariant
    assert @token != nil, "token still not set"
    assert @difficulty >= 0, "difficulty must be a number between 0 and 1"
    assert @difficulty <= 1, "difficulty must be a number between 0 and 1"
  end
end