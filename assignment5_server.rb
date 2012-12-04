require_relative "./server/server"

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

# Assignment 5 main server file, simply boots up the server.

# To run, simply run the following command:
# ruby assignment5_server.rb <port_number>

# The <port_number> argument is the port to start the server on. If it is not
# given, 50500 is used as default.

# Retrive port from ARGV array and remove it (XMLRPC uses these command line
# arguments for its own purpose so we make sure we don't throw anything it
# doesn't want)
port = ARGV[0]
if port != nil
  ARGV.delete_at(0)
else
  port = 50500
end

# Start the client
Server.new(port)