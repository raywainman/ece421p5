require_relative "./client/client"

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

# Assignment 5 main client file, simply creates an instance of the GUI and its
# controller object and binds them together.

# To run, simply run the following command:
# ruby assignment5_client.rb <port_number>

# The <port_number> argument is the port used on the local RPC server (which
# runs on the client) that is used by the server for a 2-way communication
# channel. If it is not given, 50501 is used as default.

Dir.chdir("./client")
# Retrive port from ARGV array and remove it (XMLRPC uses these command line
# arguments for its own purpose so we make sure we don't throw anything it
# doesn't want)
port = ARGV[0]
if port != nil
  ARGV.delete_at(0)
else
  port = 50501
end

# Start the client
client = Client.new(port)