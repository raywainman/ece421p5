require "test/unit"

# Common checks that are reusable.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

module CommonContracts
  include Test::Unit::Assertions
  def check_grid_array(grid)
    assert grid != nil, "Provided grid cannot be nil"
    assert grid.size == 6, "grid must have 6 rows"
    assert grid[0].size == 7, "grid must have 7 columns"
    assert grid.respond_to?("[]"), "grid must respond to []"
    assert grid[0].respond_to?("[]"), "grid[0] must respond to []"
    assert grid.respond_to?("each"), "grid must respond to each"
    assert grid.respond_to?("each_with_index"), "grid must respond to each_with_index"
    assert grid[0].respond_to?("each"), "grid[0] must respond to each"
    assert grid[0].respond_to?("each_with_index"), "grid[0] must respond to each_with_index"
    grid.each{ |row|
      row.each { |element|
        assert element == nil || element.size == 1, "element must be a token"
      }
    }
  end

  def check_active_player(active_player)
    assert active_player.is_a?(Fixnum), "active_player must be an integer"
    range = (0...4)
    assert range.include?(active_player), "active_player must be within player range"
  end

  def check_port(port)
    assert port.respond_to?("to_i"), "port must be representable as an integer"
    assert port.to_i >= 50500 && port.to_i <=50600, "port must be in 50500-50600 range"
  end

  def check_ip(ip)
    assert ip.is_a?(String), "ip value must be a string"
    assert ip.size > 0, "ip value must not be empty"
  end
  
end