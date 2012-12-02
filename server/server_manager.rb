require "json"
require "xmlrpc/client"

require_relative "./connect4"
require_relative "./game"
require_relative "./otto"

class ServerManager
  def initialize
    @games = {}
    @locks = {}
    # Create a master lock used when manipulating the two above data structures
    @master_lock = Mutex.new
  end

  def create_game(game_name, humans, ais, ai_difficulty, player, game_type, hostname, host_port)
    id = -1
    @master_lock.synchronize() {
      id = @games.size()
      # Set a placeholder for now
      @games[id] = player
      # Create a mutex for this particular game
      @locks[id] = Mutex.new
    }
    @locks[id].synchronize {
      # Game Type
      if game_type == "connect4"
        game_type_obj = Connect4.instance
      elsif game_type == "otto"
        game_type_obj = Otto.instance
      end
      # Players
      players = []
      (0...humans).each {
        players << HumanPlayer.new
      }
      players[0].set_name(player)
      server_object = XMLRPC::Client.new(hostname, "/", host_port)
      client = server_object.proxy("client")
      players[0].set_rpc(client)
      (0...ais).each { |ai_index|
        players << AIPlayer.new("Computer " + (ai_index+1).to_s, ai_difficulty)
      }
      @games[id] = Game.new(game_type_obj, players, game_name)
      puts "Created game " + id.to_s
      puts @games[id].to_s
      return id
    }
  end

  def join_game(id, player_name, hostname, host_port)
    @locks[id].synchronize {
      index = -1
      @games[id].players.each { |player|
        if player.name == ""
          player.set_name(player_name)
          server_object = XMLRPC::Client.new(hostname, "/", host_port)
          client = server_object.proxy("client")
          player.set_rpc(client)
          
          new_players = @games[id].get_player_names()
          @games[id].players.each { |other_player|
            if other_player.is_a?(HumanPlayer) && other_player != player
              puts "Updating other player"
              other_player.rpc.initialize_players(new_players)
            end
          }
          
          return true
        end
      }
      return false
    }
  end

  def get_players(id)
    @locks[id].synchronize {
      return @games[id].get_player_names()
    }
  end

  def make_move(id, player, column)
    @locks[id].synchronize {
      return @games[id].make_move(player, column)
    }
  end

  def update(id)
    @locks[id].synchronize {
      state = @games[id].get_state
      return Marshal.dump(state.grid), state.active_player
    }
  end
end
