require "xmlrpc/server"

require_relative "./main_view"
require_relative "./main_controller"

class Client
  def initialize(port)
    @view = MainView.new()
    @controller = MainController.new(@view, port)
    @view.set_controller(@controller)
    Thread.new {
      @view.show
    }
    @server = XMLRPC::Server.new(port)
  end

  def start
    @server.add_handler("client", self)
    @server.serve()
  end

  def initialize_players(players)
    @view.initialize_players(players)
  end

  def update(grid, active_player)
    @view.update(Marshal.load(grid), active_player)
    return true
  end

  def win(winner)
    @controller.set_win(winner)
    return true
  end

  def tie()
    @controller.set_win(0)
    return true
  end
end

client = Client.new(ARGV[0].to_i)
client.start()