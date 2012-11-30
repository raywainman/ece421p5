require "test/unit"

# Contracts for the Grid class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module GridContracts
  include Test::Unit::Assertions
  def grid_access_preconditions(i,j)
    assert i >= 0, "row must be >= 0"
    assert i < 6, "row must be < 6"
    assert j >= 0, "column must be >= 0"
    assert j < 7, "column must be < 7"
  end

  def pre_get_row_length()
    # No preconditions
  end

  def post_get_row_length(result)
    assert(result!=nil)
    assert(result.respond_to?("to_i"))
    assert(result >= 0)
  end

  def pre_get_column_length()
    # No preconditions
  end

  def post_get_column_length(result)
    assert(result!=nil)
    assert(result.respond_to?("to_i"))
    assert(result >= 0)
  end

  def grid_access_postconditions(result)
    # No postconditions since result can be nil
  end

  def each_preconditions()
    # No preconditions
  end

  def each_postconditions(result)
    # No postconditions
  end

  def each_with_index_preconditions()
    # No preconditions
  end

  def each_with_index_postconditions(result, row_index, column_index)
    assert row_index >= 0, "row index must be > 0"
    assert row_index < 6, "row must be < 6"
    assert column_index >= 0, "column must be >= 0"
    assert column_index < 7, "column must be < 7"
  end

  def column_preconditions(i)
    assert i >= 0, "column must be >= 0"
    assert i < 7, "column must be < 7"
  end

  def column_postconditions(result)
    assert result.size == 6, "resulting column must be of size 6"
  end

  def row_preconditions(i)
    assert i >= 0, "row must be >= 0"
    assert i < 6, "row must be < 6"
  end

  def row_postconditions(result)
    assert result.size == 7, "resulting column must be of size 7"
  end

  def reset_preconditions()
    # No preconditions for reset
  end

  def reset_postconditions()
    @grid.each{ |row|
      row.each{ |column|
        assert column == nil, "grid element must be nil to start"
      }
    }
  end

  def make_move_preconditions(token, column)
    assert token != nil, "token must not be nil"
    assert column >= 0, "column must be within range"
    assert column < 7, "column must be within range"
    assert @grid[0][column] == nil, "column is full"
  end

  def make_move_postconditions(token, column)
    # Ensure move was actually made
    added = false
    (0..6).each{ |row|
      if @grid[row][column] == token
        added = true
        break
      end
    }
    assert added, "move not recorded"
  end

  def is_column_full_preconditions(column)
    assert column >= 0, "column must be within range"
    assert column < 7, "column must be within range"
  end

  def is_column_full_postconditions()
    # No postconditions
  end

  def is_full_preconditions()
    # No preconditions
  end

  def is_full_postconditions()
    # No postconditions
  end

  def class_invariant()
    assert @grid.size == 6, "grid incorrect size"
    assert @grid[0].size == 7, "grid incorrect size"
    # Ensure number of tokens from each player is consistent
    count = Hash.new
    count.default = 0
    @grid.each{ |row|
      row.each{ |element|
        if element != nil
          count[element] = count[element] + 1
        end
      }
    }
    max_value = count.values.max
    count.values.each{ |value|
      difference = max_value - value
      assert difference.abs <= 1, "inconsistent number of tokens"
    }
  end
end