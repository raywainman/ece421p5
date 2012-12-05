require "test/unit"

require_relative "../../contracts/common_contracts"

# Contracts for the Player class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

module ServerManagerContracts
  include Test::Unit::Assertions
  include CommonContracts
  def pre_initialize
    #NONE
  end

  def post_initialize
    assert(@games!=nil, "game hash not set up initialized")
    assert(@players!=nil, "players hash not setup initialized")
    assert(@locks!=nil, "locks has is not correctly initialized")
  end

  def pre_create_game(game_name, humans, ais, ai_difficulty, player, game_type, hostname, host_port)

    #game name left alone

    assert(humans!=nil, "humans parameter cannot be nil")
    assert(humans.to_i >=0, "number of humans cannot be negative")

    assert(ais!=nil, "ais parameter cannot be nil")
    assert(ais.to_i >=0, "number of ais cannot be negative")

    assert(ai_difficulty!=nil, "ai_difficulty cannot be nil")
    assert ai_difficulty >= 0, "difficulty must be a number between 0 and 1"
    assert ai_difficulty <= 1, "difficulty must be a number between 0 and 1"

    assert(player!=nil, "player name cannot be nil")
    check_name(player)

    assert(game_type!=nil, "game type cannot be nil")
    assert(game_type.is_a?(String), "game type must be a string")
    assert(game_type.size > 0, "game type string must be > 0")

    assert(hostname!=nil, "hostname cannot be nil")
    check_name(hostname)

    assert(host_port!=nil, "host_port cannot be nil")
    check_port(host_port)
  end

  def check_game_cache(id)
    assert(id!=nil)
    assert(id >= 0)

    assert(@games[id]!=nil, "cache for game id contains nil")
    assert(@games[id].is_a?(Game), "cache for game id must be of type game")

    assert(@locks[id]!=nil, "locks not properly created for game")
    assert(@locks[id].is_a?(Mutex), "Lock for game must be a mutex")

    assert(@players[id]!=nil, "players cache not created for game")
    assert(@players[id].respond_to?("[]"), "players element must respond to []")
    assert(@players[id].respond_to?("size"), "players element must respond to size")
    assert(@players[id].respond_to?("each"), "players element must respond to each")
    assert(@players[id].size > 0, "game must have at least one player")

    @players[id].each() { |player|

      assert(player!=nil, "players element cannot be nil")
      assert(@players[id].respond_to?("[]"), "players element must respond to []")
      assert(player.respond_to?("has_key?"), "players element must respond to has_key?")
      assert(player.has_key?("ip"))
      assert(player.has_key?("port"))
    }
  end
  
  def post_create_game(id)
    check_game_cache(id)
  end
  
  def pre_join_game(id, player_name, hostname, host_port)
    assert(id != nil, "id of game cannot be nil")
    assert(id >= 0, "invalid game id provided")
    #check game complete?
    
    check_name(player_name)
    check_ip(hostname)
    check_port(host_port)
  end
  
  def post_join_game(id, result)
    if(result == true)
      check_game_cache(id)
    end
  end
  
  def pre_get_players(id)
    assert(id != nil, "id of game cannot be nil")
    assert(id >= 0, "invalid game id provided")
    assert(@games[id] != nil, "invalid game id provided")
  end
  
  def post_get_players(result)
    assert(result!=nil)
    check_player_hash(result)
  end
  
  def pre_make_move(id, player, column)
  end
  
  def post_make_move(result)
  end
  
  def pre_update(id)
  end
  
  def post_update(result)
  end  
  
  def pre_get_open_games(player_name)
  end
  
  def post_get_open_games(result)
  end
  
  def pre_get_leaderboard()
  end
  
  def post_get_leaderboard()
  end

end