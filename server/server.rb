require "xmlrpc/server"

require_relative "./server_manager"

class Server
  def initialize(port)
    @server = XMLRPC::Server.new(port, ENV["HOSTNAME"], 100)
    @server.add_handler("server", ServerManager.new())
    @server.serve()
  end
end

Server.new(ARGV[0])