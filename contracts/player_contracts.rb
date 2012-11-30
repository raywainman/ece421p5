require "test/unit"

# Contracts for the Player class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #4)

module PlayerContracts
  include Test::Unit::Assertions
  def set_token_preconditions(token)
    assert token != nil, "token must not be nil"
  end

  def set_token_postconditions()
    assert @token != nil, "token must not be nil"
  end

  def set_winning_token_preconditions(winning_token)
    assert winning_token != nil, "winning token must not be nil"
    assert winning_token.size == 4, "winning token must be length 4"
  end

  def set_winning_token_postconditions()
    assert @winning_token != nil, "winning token must not be nil"
  end
end