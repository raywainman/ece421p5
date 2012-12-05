require "xmlrpc/server"

require_relative "./server_manager"

# Main server object. Simply boots up an XMLRPC server and binds the
# ServerManager object.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

class Server
  def initialize(port = 50500)
    ip_address = ENV["HOSTNAME"]
    if ip_address == nil
      ip_address = Socket.gethostname
    end
    @server = XMLRPC::Server.new(port, ip_address, 100)
    @server.add_handler("server", ServerManager.new())
    @server.serve()
  end
end