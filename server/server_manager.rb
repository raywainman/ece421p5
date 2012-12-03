require "json"
require "xmlrpc/client"

require_relative "./connect4"
require_relative "./game"
require_relative "./otto"
require_relative "../server_database"

class ServerManager
  def initialize
    @games = {}
    @players = {}
    @locks = {}
    # Create a master lock used when manipulating the two above data structures
    @db = ServerDatabase.getInstance()
  end

  def create_game(game_name, humans, ais, ai_difficulty, player, game_type, hostname, host_port)
    begin
      # Game Type
      if game_type == "connect4"
        game_type_obj = Connect4.instance
      elsif game_type == "otto"
        game_type_obj = Otto.instance
      end
      # Players
      players = []
      human_players = []
      (0...humans).each {
        players << HumanPlayer.new
      }
      players[0].set_name(player)
      human_players << player
      (0...ais).each { |ai_index|
        players << AIPlayer.new("Computer " + (ai_index+1).to_s, ai_difficulty)
      }

      game = Game.new(game_type_obj, players, game_name)
      puts game.to_s
      id = @db.create_game_id(game_name, human_players, Marshal.dump(game))
      @games[id] = game
      @locks[id] = Mutex.new
      puts "Created game " + id.to_s
      puts hostname
      puts host_port.to_s
      server_object = XMLRPC::Client.new(hostname, "/", host_port)
      client = server_object.proxy("client")
      @players[id] = []
      @players[id] << client
      return id
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def join_game(id, player_name, hostname, host_port)
    begin
      @locks[id].synchronize {
        @games[id].players.each { |player|
          if player.name == player_name
            puts "Username is already in the game"
            return false
          end
        }
        @games[id].players.each { |player|
          if player.name == ""
            player.set_name(player_name)
            new_players = @games[id].get_player_names()
            @players[id].each { |other_player|
              other_player.initialize_players(new_players)
            }
            @db.add_restorable_player_to_game(id, player_name)
            server_object = XMLRPC::Client.new(hostname, "/", host_port)
            client = server_object.proxy("client")
            @players[id] << client
            return true
          end
        }
        return false
      }
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def get_players(id)
    begin
      @locks[id].synchronize {
        return @games[id].get_player_names()
      }
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def make_move(id, player, column)
    begin
      db = ServerDatabase.getInstance()
      @locks[id].synchronize {
        puts player
        puts column.to_s
        result = @games[id].make_move(player, column)
        db.update_game(id, Marshal.dump(@games[id]))
        grid, active_player = @games[id].get_state()
        @players[id].each { |player_rpc|
          player_rpc.update(Marshal.dump(grid), active_player)
        }
        if @games[id].winner != -1
          if @games[id].winner == -2
            @players[id].each { |player_rpc|
              player_rpc.tie()
            }
          else
            @players[id].each { |player_rpc|
              player_rpc.win(@games[id].winner_name)
            }
          end
          @db.set_game_complete(id)
          # TODO: Only collect statistics for multiplayer games
          stats = @games[id].collect_statistics
          stats["GAME_ID"] = id
          puts stats.inspect
          @db.save_statistics(stats)
        end

        return result
      }
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def update(id)
    begin
      @locks[id].synchronize {
        grid, active_player = @games[id].get_state
        return Marshal.dump(grid), active_player
      }
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def get_open_games()
    begin
      games = {}
      @games.each { |id, game|
        full = true
        game.players.each { |player|
          if player.name == ""
            full = false
          end
        }
        if !full
          games[id] = game.game_name
        end
      }
      return Marshal.dump(games)
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end
end
