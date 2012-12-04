require "xmlrpc/server"
require "socket"

require_relative "./main_view"
require_relative "./main_controller"
require_relative "./contracts/client_contracts"

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

# Client main object and RPC interface. This RPC interface is used by the
# server to communicate to the client.
class Client
  include ClientContracts
  
  # Creates an instance of the client and initializes the local RPC server that
  # is used by the server to communicate to this object.
  def initialize(port=50501)
    pre_initialize(port)
    @view = MainView.new()
    @controller = MainController.new(@view, port)
    @view.set_controller(@controller)
    # start server
    ip_address = ENV["HOSTNAME"]
    if ip_address == nil
      ip_address = Socket.gethostname
    end
    server = XMLRPC::Server.new(port, ip_address, 100)
    server.add_handler("client", self)
    # Start RPC in seperate thread so that we don't block the event thread
    Thread.new {
      server.serve()
    }
    @view.show
    post_initialize()
  end

  # CLIENT RPC METHODS

  # Initializes the players that appear at the top of the game board. Input
  # argument is simply a hash of { "token" => "player_name" }.
  def initialize_players(players)
    pre_initialize_players(players)
    puts "Received players from server - " + players.inspect
    begin
      @view.initialize_players(players)
    rescue Exception => e
      puts e
      puts e.backtrace
      @view.show_error_dialog
    end
    post_initialize_players()
  end

  # Updates the grid with the given grid values and sets the appropriate active
  # player in the list of players.
  def update(grid, active_player)
    grid = Marshal.load(grid)
    pre_update(grid, active_player)
    puts "Received update from server"
    begin
      @view.update(grid, active_player)
      return true
    rescue Exception => e
      puts e
      puts e.backtrace
      @view.show_error_dialog
    end
    post_update()
  end

  # Notifies the controller that a winner has been determined.
  def win(winner)
    pre_win(winner)
    puts "Received winner from server - " + winner
    begin
      @controller.set_win(winner)
      return true
    rescue Exception => e
      puts e
      puts e.backtrace
      @view.show_error_dialog
    end
    post_win()
  end

  # Notifies the controller that the game has resulted in a tie.
  def tie()
    pre_tie()
    puts "Received tie from server"
    begin
      @controller.set_win(0)
      return true
    rescue Exception => e
      puts e
      puts e.backtrace
      @view.show_error_dialog
    end
    post_tie()
  end
end
