require "test/unit"

# Contracts for the Player class.

# Author:: Dustin Durand (dddurand@ualberta.ca)
# Author:: Kenneth Rodas (krodas@ualberta.ca)
# Author:: Raymond Wainman (wainman@uablerta.ca)
# (ECE 421 - Assignment #5)

module ServerDatabaseContract
  include Test::Unit::Assertions
  extend Test::Unit::Assertions
  def class_invariant
    assert(@dbh != nil, "database cannot be nil")
    assert(@dbh.ping() == @dbh, "connection to db failed")
  end

  def pre_initialize(db)
    assert(db!=nil, "database cannot be nil")
    assert(db.respond_to?("ping"), "database must respond to ping")
    assert(db.respond_to?("close"), "database must respond to close")
    assert(db.respond_to?("prepare"), "database must respond to prepare")
    assert(db.respond_to?("list_tables"), "database must respond to list_tables")

    assert(db.ping() == db)

    tables = db.list_tables()
    assert(tables!=nil, "result of tables cannot be nil")
    assert(tables.respond_to?("include?"))

    assert(tables.include?("game"))
    assert(tables.include?("game_restore_players"))
    assert(tables.include?("game_results"))
    assert(tables.include?("game_results_players"))
    assert(tables.include?("player"))

    sql = "select * from game"
    prep_stat = db.prepare(sql)
    assert(prep_stat!=nil)
    assert(prep_stat.respond_to?("execute"))

    stmt = prep_stat.execute()
    assert(stmt!=nil)
    assert(stmt.respond_to?("close"))
    assert(stmt.respond_to?("num_rows"))
    assert(stmt.respond_to?("fetch"))
    assert(stmt.respond_to?("insert_id"))

    stmt.close()

  end

  def post_initialize(db)
    assert(@dbh == db)
    class_invariant
  end

  def ServerDatabaseContract.pre_getInstance()
    #None
  end

  def ServerDatabaseContract.post_getInstance(result)
    assert(result!=nil)
    assert(result.is_a?(ServerDatabase))
  end

  def pre_close_connection
    class_invariant
    #None
  end

  def post_close_connection()
    #None
  end

  def check_name(name)
    assert(name!=nil)
    assert(name.respond_to?("to_s"))

    string = name.to_s
    assert(string.is_a?(String))
    assert(string.length > 0)
    assert(string.length <= 255)
  end

  def check_database_id(id)
    assert(id!=nil)
    assert(id.respond_to?("to_i"))
    assert(id.to_i >= 0)
  end

  def pre_get_player_id(name)
    class_invariant
    check_name(name)
  end

  def post_get_player_id(id, name)
    check_database_id(id)
    assert(player_exist?(name) >= 0)
    class_invariant
  end

  def check_db_limits(limit_start, number_of_records)

    if(number_of_records!=nil)
      assert(limit_start!=nil)
      assert(limit_start.is_a?(Integer))
      assert(limit_start>=0)

      assert(number_of_records.is_a?(Integer))
      assert(number_of_records>0)
    end
  end

  def pre_add_restorable_player_to_game(game_id, name)
    class_invariant
    check_database_id(game_id)
    assert(gameExist?(game_id))
    assert(!gameComplete?(game_id))
    check_name(name)
  end

  def post_add_restorable_player_to_game(result)
    check_database_id(result)
    class_invariant
  end

  def pre_get_wins(name, limit_start, number_of_records)
    class_invariant
    check_name(name)
    check_db_limits(limit_start, number_of_records)
  end

  def check_count_result(result)
    assert(result!=nil)
    assert(result.is_a?(Integer))
    assert(result>=0)
  end

  def post_get_wins(result)
    check_count_result(result)
    class_invariant
  end

  def pre_get_loses(name, limit_start, number_of_records)
    class_invariant
    check_name(name)
    check_db_limits(limit_start, number_of_records)
  end

  def post_get_loses(result)
    check_count_result(result)
    class_invariant
  end

  def pre_get_draws(name, limit_start, number_of_records)
    class_invariant
    check_name(name)
    check_db_limits(limit_start, number_of_records)
  end

  def post_get_draws(result)
    check_count_result(result)
    class_invariant
  end

  def check_average_result(result)
    assert(result!=nil)
    assert(result.is_a?(Float))
    assert(result>=0)
  end

  def pre_get_leader_board()
    #None
  end

  def post_get_leader_board(result)
    assert(result!=nil)
    assert(result.respond_to?("[]"))
    assert(result.respond_to?("each"))

    result.each() {|x|
      assert(x!=nil)
      assert(x.respond_to?("[]"))
      assert(x.respond_to?("has_key?"))
      assert(x.respond_to?("size"))

      assert(x.has_key?("NAME"))
      assert(x.has_key?("WINS"))
      assert(x.has_key?("LOSES"))
      assert(x.has_key?("DRAWS"))
      assert(x.has_key?("AVG_TOKENS"))
      assert(x.has_key?("AVG_TOKENS_WINS"))
    }

  end

  def pre_sort_leader_board(array)
    post_get_leader_board(array)
  end

  def post_sort_leader_board(array)
    post_get_leader_board(array)

    previous_wins = Integer::MAX
    previous_losses = 0
    previous_draws = Integer::MAX
    array.each() { |x|
      assert(x["WINS"] >= previous_wins)

      if(x["WINS"] == previous_wins)
        assert(x["LOSES"] <= previous_losses)
      end

      if(x["WINS"] == previous_wins && x["LOSES"] == previous_losses)
        assert(x["DRAWS"] >= previous_draws)
      end

    }

  end

  def pre_get_avg_tokens_for_win(name, limit_start, number_of_records)
    class_invariant
    check_name(name)
    check_db_limits(limit_start, number_of_records)
  end

  def post_get_avg_tokens_for_win(result)
    check_average_result(result)
    class_invariant
  end

  def pre_get_avg_tokens(name, limit_start, number_of_records)
    class_invariant
    check_name(name)
    check_db_limits(limit_start, number_of_records)
  end

  def post_get_avg_tokens(result)
    check_average_result(result)
    class_invariant
  end

  def pre_create_game_id(game_name, players, game_obj)
    class_invariant
    check_name(game_name)

    assert(players!=nil)
    assert(players.respond_to?("each"))
    assert(players.respond_to?("size"))
    assert(players.size > 0)

    players.each { |player|
      check_name(game_name)
    }

    assert(game_obj!=nil)

  end

  def post_create_game_id(id)
    check_database_id(id)
    assert(gameExist?(id))
    class_invariant
  end

  def pre_update_game(id, data)
    class_invariant
    check_database_id(id)
    assert(data!=nil)
    assert(gameExist?(id))
    assert(!gameComplete?(id))
  end

  def post_update_game
    #None
    class_invariant
  end

  def pre_set_game_complete(id)
    class_invariant
    check_database_id(id)
    assert(gameExist?(id))
    assert(!gameComplete?(id))
  end

  def post_set_game_complete(id)
    assert(gameComplete?(id))
    class_invariant
  end

  def pre_retrieve_incomplete_game_data(id)
    class_invariant
    check_database_id(id)
    assert(gameExist?(id))
    assert(!gameComplete?(id))
  end

  def post_retrieve_incomplete_game_data(data)
    assert(data!=nil)
    class_invariant
  end

  def pre_retrieve_incomplete_games_for_player(name, limit_start, number_of_records)
    class_invariant
    check_name(name)
    check_db_limits(limit_start, number_of_records)
  end

  def post_retrieve_incomplete_games_for_player(result, number_of_records)
    assert(result!=nil)
    assert(result.is_a?(Array))

    if(number_of_records!= nil)
      result.size <= number_of_records
    end

    result.each() {|element|
      assert(element!=nil)
      assert(element.is_a?(Array))
      assert(element.size == 2)
      check_database_id(element[0])
      check_name(element[1])

    }
    class_invariant
  end

  def pre_save_statistics(hash)
    class_invariant
    assert(hash!=nil)
    assert(hash.respond_to?("[]"))
    assert(hash.respond_to?("has_key?"))

    assert(hash.has_key?("GAME_ID"))
    assert(hash.has_key?("PLAYERS"))

    players = hash["PLAYERS"]
    assert(players!=nil)
    assert(players.respond_to?("each_pair"))
    assert(players.respond_to?("size"))
    assert(players.size > 0)

    players.each_pair do |name,tokens|
      check_name(name)
      assert(tokens!=nil)
      assert(tokens.respond_to?("to_i"))
      assert(tokens.to_i > 0)
    end

  end

  def post_save_statistics(game_results_id)
    check_database_id(game_results_id)
    class_invariant
  end

  def pre_get_recent_games(player_name, limit_start, number_of_records)
    class_invariant
    check_name(player_name)
    check_db_limits(limit_start, number_of_records)
  end

  def post_get_recent_games(result, number_of_records)

    assert(result!=nil)
    assert(result.is_a?(Array))

    if(number_of_records!= nil)
      result.size <= number_of_records
    end

    result.each() {|element|
      assert(element!=nil)
      assert(element.is_a?(Array))
      assert(element.size == 3)
      check_name(element[0])
      char = element[1]
      assert(char == "w" || char == "l" || char == "d")
      assert(element[2]!=nil)
      assert(element[2].respond_to?("to_i"))
      assert(element[2].to_i > 0)

    }
    class_invariant
  end

  def pre_addGame(game_name, data)
    class_invariant
    check_name(game_name)
    assert(data!=nil)
  end

  def post_addGame(result)
    check_database_id(result)
    gameExist?(result)
    class_invariant
  end

  def pre_addGameResults(game_id, winner_id)
    class_invariant
    check_database_id(game_id)

    if(winner_id!= -1)
      check_database_id(winner_id)
    end

    assert(gameExist?(game_id))

  end

  def post_addGameResults(result)
    check_database_id(result)
    class_invariant
  end

  def pre_player_exist_id?(id)
    check_database_id(id)
    class_invariant
  end

  def post_player_exist_id?(result)
    assert(result == true || result == false)
  end

  def pre_addRestorablePlayer(game_id, player_id)
    class_invariant
    check_database_id(game_id)
    check_database_id(player_id)

    assert(gameExist?(game_id))
    assert(player_exist_id?(player_id))
    class_invariant
  end

  def post_addRestorablePlayer(result)
    check_database_id(result)
    class_invariant
  end

  def pre_addPlayerGameResults(game_results_id, player_id, tokens)
    class_invariant
    check_database_id(game_results_id)
    check_database_id(player_id)
    assert(player_exist_id?(player_id))
    assert(tokens!=nil)
    assert(tokens.respond_to?("to_i"))
    assert(tokens.to_i > 0)

  end

  def post_addPlayerGameResults(result)
    check_database_id(result)
    class_invariant
  end

  def pre_gameExist?(game_id)
    class_invariant
    check_database_id(game_id)
  end

  def post_gameExist?(result)
    assert(result==true || result==false)
    class_invariant
  end

  def pre_gameComplete?(game_id)
    class_invariant
    check_database_id(game_id)
    gameExist?(game_id)
  end

  def post_gameComplete?(result)
    assert(result==true || result==false)
    class_invariant
  end

  def pre_player_exist?(name)
    class_invariant
    check_name(name)
  end

  def post_player_exist?(result)
    assert(result==-1 || result >= 0)
    class_invariant
  end

  def pre_get_single_row_field(sql, empty_default, *args)
    class_invariant
    assert(sql!=nil)
    assert(sql.is_a?(String))
    assert(sql.count("?") == args.length)
  end

  def post_get_single_row_field(result)
    #None
    class_invariant
  end

  def pre_player_create(name)
    class_invariant
    check_name(name)
    assert(player_exist?(name) == -1)
  end

  def post_player_create(name)
    assert(player_exist?(name)>=0)
    class_invariant
  end

  def pre_insert_row(sql, *args)
    class_invariant
    assert(sql!=nil)
    assert(sql.is_a?(String))
    assert(sql.count("?") == args.length)
  end

  def post_insert_row(result)
    check_database_id(result)
    class_invariant
  end

end