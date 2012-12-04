require "xmlrpc/server"

require_relative "./server_manager"

class Server
  def initialize(port = 50500)
    ip_address = ENV["HOSTNAME"]
    if ip_address == nil
      ip_address = Socket.gethostname
    end
    puts ip_address
    @server = XMLRPC::Server.new(port, ip_address, 100)
    @server.add_handler("server", ServerManager.new())
    @server.serve()
  end
end

# Remove the port argument since the RPC server seems to run whatever it is in
# the arguments list as a file upon shutdown
port = ARGV[0]
ARGV.delete_at(0)
Server.new(port)