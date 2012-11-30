require_relative "./contracts/game_type_contracts"

# Abstract game type class. Variants must implement the methods defined in
# in this class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

class GameType
  include GameTypeContracts
  
  # Gets the label that should be given to the given player number
  def get_player_label(player)
    raise "Not implemented"
  end

  # Returns the maximum number of players that can play in this mode
  def max_players()
    raise "Not implemented"
  end

  # Returns the minimum number of players needed to play in this mode
  def min_players()
    raise "Not implemented"
  end

  # Returns a string representing the game
  def game_name()
    raise "Not implemented"
  end
  
  # Returns the winning token for the given player
  def winning_token(player)
    raise "Not implemented"
  end

  # Evaluates the grid and returns true if the winning token is found
  def evaluate_win(grid, winning_token)
    evaluate_win_preconditions(grid, winning_token)

    expected_length = winning_token.length()
    sentinel = ";"
    null_token = "^"

    matches= evaluate_horizontal_win(grid, sentinel, null_token, expected_length)
    matches+= evaluate_vertical_win(grid, sentinel, null_token, expected_length)
    matches+= evaluate_right_diagonal_win(grid, sentinel, null_token, expected_length)
    matches+= evaluate_left_diagonal_win(grid, sentinel, null_token, expected_length)

    result = /#{winning_token}/.match(matches)

    if(result == nil)
      return false
    else
      return true
    end
    evaluate_win_postconditions()
  end

  private

  def evaluate_horizontal_win(grid, sentinal, null_token, expected_length)
    pre_evaluate_horizontal_win(grid, sentinal, null_token, expected_length)

    result = "";

    row_length = grid.get_row_length()
    col_length = grid.get_column_length()

    row_length.times { |rowindex|
      col = 0
      while(col + expected_length-1 < col_length)
        string = ""
        col.upto(col+expected_length-1) {|i|
          temp = grid[rowindex,i]

          if(temp == nil)
            string += null_token
          else
            string += temp.to_s
          end
        }
        result += string + sentinal
        col+= 1
      end
    }
    post_evaluate_horizontal_win(result)
    result
  end

  def evaluate_vertical_win(grid, sentinal, null_token, expected_length)
    pre_evaluate_vertical_win(grid, sentinal, null_token, expected_length)
    result = ""

    row_length = grid.get_row_length()
    col_length = grid.get_column_length()

    col_length.times { |col|
      row = 0
      while(row + expected_length-1 < row_length)
        string = ""
        (row..row+expected_length-1).each {|i|
          temp = grid[i,col]
          if(temp == nil)
            string += null_token
          else
            string += temp.to_s
          end
        }
        result += string + sentinal
        row+= 1
      end
    }
    post_evaluate_vertical_win(result)
    result
  end

  def evaluate_right_diagonal_win(grid, sentinal, null_token, expected_length)

    pre_evaluate_right_diagonal_win(grid, sentinal, null_token, expected_length)
    result = ""

    row_length = grid.get_row_length()
    col_length = grid.get_column_length()

    row_length.times { |row|
      col_length.times { |col|
        if([row_length - row, col + 1].min < expected_length)
          next
        end
        column_index = col
        row_index = row
        string = ""
        while(row_index < row_length && column_index >= 0 && string.length <  expected_length)
          temp = grid[row_index,column_index]

          if(temp == nil)
            string += null_token
          else
            string += temp.to_s
          end

          row_index+=1
          column_index-=1
        end

        if(string.length == expected_length)
          result+= string + sentinal
        end
      }
    }

    post_evaluate_right_diagonal_win(result)
    result
  end

  def evaluate_left_diagonal_win(grid, sentinal, null_token, expected_length)
    pre_evaluate_left_diagonal_win(grid, sentinal, null_token, expected_length)
    result = ""

    row_length = grid.get_row_length()
    col_length = grid.get_column_length()

    row_length.times { |row|
      col_length.times { |col|
        if([row_length - row, col_length - col].min < expected_length)
          next
        end
        column_index = col
        row_index = row
        string = ""
        while(row_index < row_length && column_index < col_length && string.length < expected_length)
          temp = grid[row_index,column_index]
          if(temp == nil)
            string += null_token
          else
            string += temp.to_s
          end
          row_index+=1
          column_index+=1
        end
        if(string.length == expected_length)
          result+= string + sentinal
        end
      }
    }
    post_evaluate_left_diagonal_win(result)
    result
  end
end
