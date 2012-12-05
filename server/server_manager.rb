require "json"
require "xmlrpc/client"

require_relative "./connect4"
require_relative "./game"
require_relative "./otto"
require_relative "./server_database"
require_relative "./contracts/server_manager_contracts"

class ServerManager
  include ServerManagerContracts
  def initialize
    pre_initialize
    @games = {}
    @players = {}
    @locks = {}
    post_initialize
  end

  def create_game(game_name, humans, ais, ai_difficulty, player, game_type, hostname, host_port)
    pre_create_game(game_name, humans, ais, ai_difficulty, player, game_type, hostname, host_port)

    id = -1
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
      db = ServerDatabase.getInstance()
      id = db.create_game_id(game_name, human_players, Marshal.dump(game))
      db.close_connection()
      @games[id] = game
      @locks[id] = Mutex.new
      puts "Created game " + id.to_s
      puts hostname
      puts host_port.to_s
      client = {"ip" => hostname, "port"=>host_port}
      @players[id] = []
      @players[id] << client
    rescue Exception => e
      puts e
      puts e.backtrace
    end

    post_create_game(id)
    id
  end

  def join_game(id, player_name, hostname, host_port)
    pre_join_game(id, player_name, hostname, host_port)
    result = false
    begin
      if !@locks.has_key?(id)
        @locks[id] = Mutex.new
        db = ServerDatabase.getInstance()
        @games[id] = Marshal.load(db.retrieve_incomplete_game_data(id))
        db.close_connection()
        @players[id] = []
      end
      @locks[id].synchronize {
        contains_player = false
        @games[id].players.each { |player|
          if player.name == player_name
            contains_player = true
          end
        }
        
        @games[id].players.each { |player|
          if (player.name == "" && !contains_player) || player.name == player_name
            player.set_name(player_name)
            new_players = @games[id].get_player_names()
            db = ServerDatabase.getInstance()
            db.add_restorable_player_to_game(id, player_name)
            db.close_connection()
            client = {"ip" => hostname, "port"=>host_port}
            @players[id] << client
            grid, active_player = @games[id].get_state()
            @players[id].each { |other_player|
              puts "initialize calls to clients"
              get_rpc(other_player).initialize_players(new_players)
              get_rpc(other_player).update(Marshal.dump(grid), active_player)
            }
            result = true
          end
        }
      }
    rescue Exception => e
      puts e
      puts e.backtrace
    end

    post_join_game(id, result)
    result
  end

  def get_players(id)
    pre_get_players(id)
    result = {}
    begin
      @locks[id].synchronize {
        result = @games[id].get_player_names()
      }
    rescue Exception => e
      puts e
      puts e.backtrace
    end
    post_get_players(result)
    result
  end

  def make_move(id, player, column)
    begin
      @locks[id].synchronize {
        puts player
        puts column.to_s

        if(@games[id].winner != -1)
          return false
        end
        
        if(@games[id].is_column_full?(column))
          return false
        end

        result = @games[id].make_move(player, column)

        db = ServerDatabase.getInstance()
        db.update_game(id, Marshal.dump(@games[id]))
        db.close_connection()
        grid, active_player = @games[id].get_state()
        @players[id].each { |player_rpc|
          get_rpc(player_rpc).update(Marshal.dump(grid), active_player)
        }
        if @games[id].winner != -1
          if @games[id].winner == -2
            @players[id].each { |player_rpc|
              get_rpc(player_rpc).tie()
            }
          else
            @players[id].each { |player_rpc|
              get_rpc(player_rpc).win(@games[id].winner_name)
            }
          end
          db = ServerDatabase.getInstance()
          db.set_game_complete(id)
          
          if(!@games[id].is_single_player?())
            stats = @games[id].collect_statistics
            stats["GAME_ID"] = id
            puts stats.inspect
            db.save_statistics(stats)
          end
          
          
          db.close_connection()
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

  def get_open_games(player_name)
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
      db = ServerDatabase.getInstance()
      incomp = db.retrieve_incomplete_games_for_player(player_name)
      db.close_connection()
      incomp.each { |incom_game|
        games[incom_game[0]] = incom_game[1]
      }
      return Marshal.dump(games)
    rescue Exception => e
      puts e
      puts e.backtrace
    end
  end

  def get_leaderboard()
    db = ServerDatabase.getInstance()
    result = Marshal.dump(db.get_leader_board())
    db.close_connection()
    return Marshal.dump(ServerDatabase.getInstance().get_leader_board())
  end

  private

  def get_rpc(player)
    client_object = XMLRPC::Client.new(player["ip"], "/", player["port"])
    return client_object.proxy("client")
  end
end
