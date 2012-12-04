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

    assert(db.ping() == db, "Database not reachable")

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
    assert(prep_stat!=nil, "prepare commad cannot return nil")
    assert(prep_stat.respond_to?("execute"), "object returned by prepared statement must respond to execute")

    stmt = prep_stat.execute()
    assert(stmt!=nil, "result of execute command cannot be nil")
    assert(stmt.respond_to?("close"), "statement must respond to close")
    assert(stmt.respond_to?("num_rows"), "statement must respond to # rows")
    assert(stmt.respond_to?("fetch"), "statement must respond to fetch")
    assert(stmt.respond_to?("insert_id"), "statement must respond to insert_id")

    stmt.close()

  end

  def post_initialize(db)
    assert(@dbh == db, "database instance var not assigned")
    class_invariant
  end

  def ServerDatabaseContract.pre_getInstance()
    #None
  end

  def ServerDatabaseContract.post_getInstance(result)
    assert(result!=nil, "result of get instance cannot be nil")
    assert(result.is_a?(ServerDatabase), "get instance must return a serverdatabase obj")
  end

  def pre_close_connection
    class_invariant
    #None
  end

  def post_close_connection()
    #None
  end

  def check_name(name)
    assert(name!=nil, "name parameter cannot be nil")
    assert(name.respond_to?("to_s"), "name must respond to to_s")

    string = name.to_s
    assert(string.is_a?(String), "to_s must result in a string")
    assert(string.length > 0, "name length must be greater than 0")
    assert(string.length <= 255, "name length must be less than 255")
  end

  def check_database_id(id)
    assert(id!=nil, "database id parameter cannot be nil")
    assert(id.respond_to?("to_i"), "database parameter must respond to to_i")
    assert(id.to_i >= 0, "id must be greater than or equal to 0")
  end

  def pre_get_player_id(name)
    class_invariant
    check_name(name)
  end

  def post_get_player_id(id, name)
    check_database_id(id)
    assert(player_exist?(name) >= 0, "id of created player must be greater than or equal to 0")
    class_invariant
  end

  def check_db_limits(limit_start, number_of_records)

    if(number_of_records!=nil)
      assert(limit_start!=nil, "when # of records given, limit start cannot be nil")
      assert(limit_start.is_a?(Integer), "limit start must be an integer")
      assert(limit_start>=0, "limit start must be >= 0")

      assert(number_of_records.is_a?(Integer), "# records must be an integer")
      assert(number_of_records>0, "# records must be >0")
    end
  end

  def pre_add_restorable_player_to_game(game_id, name)
    class_invariant
    check_database_id(game_id)
    assert(gameExist?(game_id), "game must exist to add restorable player")
    assert(!gameComplete?(game_id), "game must not be complete to add restorable player")
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
    assert(result!=nil, "count result cannot be nil")
    assert(result.is_a?(Integer), "result must be an integer")
    assert(result>=0, "result must be >=0")
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
    assert(result!=nil, "avg result cannot be nil")
    assert(result.is_a?(Float), "result must be a float")
    assert(result>=0, "result must be >=0")
  end

  def pre_get_leader_board()
    #None
  end

  def post_get_leader_board(result)
    assert(result!=nil, "leader board result cannot be nil")
    assert(result.respond_to?("[]"), "result must respond to []")
    assert(result.respond_to?("each"), "result must respond to each")

    result.each() {|x|
      assert(x!=nil, "element in result cannot be nil")
      assert(x.respond_to?("[]"), "element must respond to []")
      assert(x.respond_to?("has_key?"), "element must respond to has_key?")
      assert(x.respond_to?("size"), "element must respond to size")

      assert(x.has_key?("NAME"), "element must have NAME key")
      assert(x.has_key?("WINS"), "element must have WINS key")
      assert(x.has_key?("LOSES"), "element must have LOSES key")
      assert(x.has_key?("DRAWS"), "element must have DRAWS key")
      assert(x.has_key?("AVG_TOKENS"), "element must have AVG_TOKENS key")
      assert(x.has_key?("AVG_TOKENS_WINS"), "element must have AVG_TOKENS_WINS key")
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
      assert(x["WINS"] >= previous_wins, "invalid order of leaderboard detected")

      if(x["WINS"] == previous_wins)
        assert(x["LOSES"] <= previous_losses, "invalid order of leaderboard detected")
      end

      if(x["WINS"] == previous_wins && x["LOSES"] == previous_losses)
        assert(x["DRAWS"] >= previous_draws, "invalid order of leaderboard detected")
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

    assert(players!=nil, "players param cannot be nil")
    assert(players.respond_to?("each"), "players must respond to each")
    assert(players.respond_to?("size"), "players must respond to size")
    assert(players.size > 0, "number of players must be > 0")

    players.each { |player|
      check_name(game_name)
    }

    assert(game_obj!=nil)

  end

  def post_create_game_id(id)
    check_database_id(id)
    assert(gameExist?(id), "game created must exist")
    class_invariant
  end

  def pre_update_game(id, data)
    class_invariant
    check_database_id(id)
    assert(data!=nil, "data cannot be nil")
    assert(gameExist?(id), "game must exist to update state")
    assert(!gameComplete?(id), "cannot update state for complete games")
  end

  def post_update_game
    #None
    class_invariant
  end

  def pre_set_game_complete(id)
    class_invariant
    check_database_id(id)
    assert(gameExist?(id), "cannot set game complete for non-existant game")
    assert(!gameComplete?(id), "can only set incomplete game to complete")
  end

  def post_set_game_complete(id)
    assert(gameComplete?(id), "game not set to complete")
    class_invariant
  end

  def pre_retrieve_incomplete_game_data(id)
    class_invariant
    check_database_id(id)
    assert(gameExist?(id), "game must exist")
    assert(!gameComplete?(id), "game pulled is already complete")
  end

  def post_retrieve_incomplete_game_data(data)
    assert(data!=nil, "data provided cannot be nil")
    class_invariant
  end

  def pre_retrieve_incomplete_games_for_player(name, limit_start, number_of_records)
    class_invariant
    check_name(name)
    check_db_limits(limit_start, number_of_records)
  end

  def post_retrieve_incomplete_games_for_player(result, number_of_records)
    assert(result!=nil, "result cannot be nil")
    assert(result.is_a?(Array), "result should be wrapped in an array")

    if(number_of_records!= nil)
      assert(result.size <= number_of_records, "limits not enforced")
    end

    result.each() {|element|
      assert(element!=nil, "element in result cannot be nil")
      assert(element.is_a?(Array), "Element invalid")
      assert(element.size == 2, "element invalid")
      check_database_id(element[0])
      check_name(element[1])

    }
    class_invariant
  end

  def pre_save_statistics(hash)
    class_invariant
    assert(hash!=nil, "result has cannot be nil")
    assert(hash.respond_to?("[]"), "result must respond to []")
    assert(hash.respond_to?("has_key?"), "result must respond to has_key?")

    assert(hash.has_key?("GAME_ID"), "result must have key GAME_ID")
    assert(hash.has_key?("PLAYERS"), "result must have key PLAYERS")

    players = hash["PLAYERS"]
    assert(players!=nil)
    assert(players.respond_to?("each_pair"), "players must respond to each_pair")
    assert(players.respond_to?("size"), "players must respond to size")
    assert(players.size > 0, "players must contain at least one person")

    players.each_pair do |name,tokens|
      check_name(name)
      assert(tokens!=nil, "token count in player cannot be nil")
      assert(tokens.respond_to?("to_i"), "tokens must respond to to_i")
      assert(tokens.to_i > 0, "tokens must be > 0")
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

    assert(result!=nil, "recent game result cannot be nil")
    assert(result.is_a?(Array), "invalid result detected")

    if(number_of_records!= nil)
      assert(result.size <= number_of_records, "limit not enforced")
    end

    result.each() {|element|
      assert(element!=nil, "element cannot be nil")
      assert(element.is_a?(Array), "invalid element")
      assert(element.size == 3, "element size must be 3")
      check_name(element[0])
      char = element[1]
      assert(char == "w" || char == "l" || char == "d", "invalid win identifier")
      assert(element[2]!=nil, "element cannot be nil")
      assert(element[2].respond_to?("to_i"))
      assert(element[2].to_i > 0,"tokens must be > 0")

    }
    class_invariant
  end

  def pre_addGame(game_name, data)
    class_invariant
    check_name(game_name)
    assert(data!=nil, "data cannot be nil")
  end

  def post_addGame(result)
    check_database_id(result)
    assert(gameExist?(result), "game should exist")
    class_invariant
  end

  def pre_addGameResults(game_id, winner_id)
    class_invariant
    check_database_id(game_id)

    if(winner_id!= -1)
      check_database_id(winner_id)
    end

    assert(gameExist?(game_id), "game must exist to add results")

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
    assert(result == true || result == false, "invalid result detected")
  end

  def pre_addRestorablePlayer(game_id, player_id)
    class_invariant
    check_database_id(game_id)
    check_database_id(player_id)

    assert(gameExist?(game_id), "game must exist")
    assert(player_exist_id?(player_id), "player must exist")
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
    assert(player_exist_id?(player_id), "player must exist")
    assert(tokens!=nil, "tokens cannot be nil")
    assert(tokens.respond_to?("to_i"), "must respond to to_i")
    assert(tokens.to_i > 0, "tokens must be > 0")

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
    assert(result==true || result==false, "invalid result detected")
    class_invariant
  end

  def pre_gameComplete?(game_id)
    class_invariant
    check_database_id(game_id)
    assert(gameExist?(game_id), "game must exist")
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
    assert(result==-1 || result >= 0, "invalid result detected")
    class_invariant
  end

  def pre_get_single_row_field(sql, empty_default, *args)
    class_invariant
    assert(sql!=nil, "invalid sql statement")
    assert(sql.is_a?(String), "invalid sql")
    assert(sql.count("?") == args.length, "invalid number of parameters for sql statement")
  end

  def post_get_single_row_field(result)
    #None
    class_invariant
  end

  def pre_player_create(name)
    class_invariant
    check_name(name)
    assert(player_exist?(name) == -1, "player already exists")
  end

  def post_player_create(name)
    assert(player_exist?(name)>=0, "player must exist")
    class_invariant
  end

  def pre_insert_row(sql, *args)
    class_invariant
    assert(sql!=nil, "invalid sql")
    assert(sql.is_a?(String), "invalid sql")
    assert(sql.count("?") == args.length, "invalid number of parameters for sql")
  end

  def post_insert_row(result)
    check_database_id(result)
    class_invariant
  end

end