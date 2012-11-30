require_relative "./contracts/grid_contracts"

# Generic grid object (data structure) used for the Connect4 game
# and its variants.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class Grid
  include Enumerable
  include GridContracts
  # Creates a new empty grid
  def initialize()
    @grid = Array.new(6) { Array.new(7) }
  end

  # Returns the number of rows in the grid
  def get_row_length()
    pre_get_row_length()
    class_invariant()
    result = @grid.length
    class_invariant()
    post_get_row_length(result)
    result
  end

  # Returns the number of columns in the grid
  def get_column_length()
    pre_get_column_length()
    class_invariant()
    result = @grid[0].length
    class_invariant()
    post_get_column_length(result)
    result
  end

  # Gets the token at row i and column j
  def [](i,j)
    grid_access_preconditions(i,j)
    class_invariant()
    result = @grid[i][j]
    class_invariant()
    grid_access_postconditions(result)
    return result
  end

  # Gets each element from the grid starting in the the top left
  def each
    each_preconditions()
    class_invariant()
    (0...6).each{ |row_index|
      (0...7).each {|column_index|
        result = self[row_index, column_index]
        class_invariant()
        each_postconditions(result)
        yield result
      }
    }
  end

  # Gets each element from the grid starting in the the top left with its
  # row and column positions {|element, row, col|}
  def each_with_index
    each_with_index_preconditions()
    class_invariant()
    (0...6).each{ |row_index|
      (0...7).each {|column_index|
        result = self[row_index, column_index]
        class_invariant()
        each_with_index_postconditions(result, row_index, column_index)
        yield result, row_index, column_index
      }
    }
  end

  # Retrieves the given column of the grid
  def column(i)
    column_preconditions(i)
    class_invariant()
    column = Array.new(row_size)
    (0...6).each{|row_index| column[row_index] = self[row_index,i] }
    class_invariant()
    column_postconditions(column)
    return column
  end

  # Retrieves the given row of the grid
  def row(i)
    row_preconditions(i)
    class_invariant()
    row = Array.new(column_size)
    (0...7).each{|col_index| row[col_index] = self[i, col_index] }
    class_invariant()
    row_postconditions(row)
    return row
  end

  # Resets the game board to the initial state
  def reset()
    reset_preconditions()
    class_invariant()
    @grid.each_with_index{ |row_e, row_i|
      row_e.each_index{ |col_i|
        @grid[row_i][col_i] = nil
      }
    }
    class_invariant()
    reset_postconditions()
  end

  # Makes a move for the given player token on the given column
  def make_move(token, column)
    make_move_preconditions(token, column)
    class_invariant()
    (0..6).each{ |row|
      if @grid[6-row-1][column] == nil
        @grid[6-row-1][column] = token
        break;
      end
    }
    #class_invariant()
    #make_move_postconditions(token, column)
  end

  # Checks to see if the given column is full
  def is_column_full?(column)
    is_column_full_preconditions(column)
    class_invariant()
    result = @grid[0][column] != nil
    class_invariant()
    is_column_full_postconditions
    return result
  end

  # Checks to see if the game board is full
  def is_full?()
    is_full_preconditions()
    class_invariant()
    result = true
    self.each { |e|
      if e == nil
        result = false
        break
      end
    }
    class_invariant()
    is_full_postconditions()
    return result
  end

  def to_s
    str = ""
    @grid.each { |row|
      row.each { |element|
        if element == nil
          element = "-"
        end
        str << element + " "
      }
      str << "\n"
    }
    return str
  end
end