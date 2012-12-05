require "test/unit"

# Contracts for the AIPlayer class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)
  
module ServerContracts
  include Test::Unit::Assertions
  include CommonContracts
  
  def pre_initialize(port)
    check_port(port)
  end
  
  def post_initialize()
    assert(@server!=nil, "internal state incorrectly initialized")
    class_invariant()
  end
  
  def class_invariant()
    assert(@server!=nil, "internal state corrupted")
  end
  
end