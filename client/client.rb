require "xmlrpc/server"

require_relative "./main_view"
require_relative "./main_controller"

class Client
  def initialize(port=50000)
    @view = MainView.new()
    @controller = MainController.new(@view, port)
    @view.set_controller(@controller)
    Thread.new {
      @view.show
    }
    @server = XMLRPC::Server.new(port, ENV["HOSTNAME"])
  end

  def start
    @server.add_handler("client", self)
    @server.serve()
  end

  def initialize_players(players)
    begin
      @view.initialize_players(players)
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def update(grid, active_player)
    begin
      @view.update(Marshal.load(grid), active_player)
      return true
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def win(winner)
    begin
      @controller.set_win(winner)
      return true
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def tie()
    begin
      @controller.set_win(0)
      return true
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end
end

client = Client.new(ARGV[0].to_i)
client.start()