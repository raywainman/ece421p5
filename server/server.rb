require "xmlrpc/server"

require_relative "./server_manager"

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