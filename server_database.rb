require "mysql"

class ServerDatabase

  @@HOST = "localhost"
  @@USER = "root"
  @@PASS = "asdf"
  @@DB = "ECE421P5"
  @@NOT_FOUND_ID = -1
  
  
  def initialize(dbConnection)
    @dbh = dbConnection
  end
  private_class_method :new

  #Returns a new instance of our database object
  #A new instance is required for each seperate thread
  def ServerDatabase.getInstance()
    result = nil

    begin
      dbh = Mysql.real_connect(@@HOST, @@USER, @@PASS, @@DB)
      result = new(dbh)
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      raise
    end

    return result
  end

  #Closes connection to DB
  #Attempting to use this class after this call will cause exceptions (add to asserts?)
  def close_connection()
    generic_exception_handler{
      @dbh.close()
    }
  end

  #Retrieves an ID for the player
  def get_player_id(name)

    #assert not empty name

    player_id = player_exist?(name)

    if(player_id == @@NOT_FOUND_ID)
      player_id = player_create(name)
    end

    player_id
  end

  #Returns the number of wins for the given player
  #
  #Not required
  #limit_start is where the index should start
  #number_of_records is the number of records to pull maximum(from most recently won)
  def get_wins(name, limit_start = 0, number_of_records = nil)
    id = get_player_id(name)

    sql = "select count(*) from game_results gr "
    sql += "where winnerid=? "
    sql += " ORDER BY gr.completed_date DESC"

    if(number_of_records != nil)
      sql += " LIMIT #{limit_start}, #{number_of_records}"
    end

    result = get_single_row_field(sql, 0, id)

    result
  end

  #Returns the number of loses for the given player
  #
  #Not required
  #limit_start is where the index should start
  #number_of_records is the number of records to pull maximum(from most recently won)
  def get_loses(name, limit_start = 0, number_of_records = nil)
    id = get_player_id(name)

    sql = "select count(*) from game_results gr, game_results_players gp "
    sql += "where gr.id=gp.game_results_id and gr.winnerid != ? and gr.winnerid != ? and gp.player_id= ? "
    sql += "ORDER BY gr.completed_date DESC"

    if(number_of_records != nil)
      sql += " LIMIT #{limit_start}, #{number_of_records}"
    end

    result = get_single_row_field(sql, 0, id, @@NOT_FOUND_ID, id)

    result
  end

  #Returns the number of draws for the given player
  #
  #Not required
  #limit_start is where the index should start
  #number_of_records is the number of records to pull maximum(from most recently won)
  def get_draws(name, limit_start = 0, number_of_records = nil)
    id = get_player_id(name)

    sql = "select count(*) from game_results gr, game_results_players gp "
    sql += "where gr.id=gp.game_results_id and gr.winnerid = ? and gp.player_id= ? "
    sql += "ORDER BY gr.completed_date DESC"

    if(number_of_records != nil)
      sql += " LIMIT #{limit_start}, #{number_of_records}"
    end

    result = get_single_row_field(sql, 0, @@NOT_FOUND_ID, id)

    result
  end

  #Returns the number of average tokens needed for a win for the given player
  #
  #Not required
  #limit_start is where the index should start
  #number_of_records is the number of records to pull maximum(from most recently won)
  def get_avg_tokens_for_win(name, limit_start = 0, number_of_records = nil)
    id = get_player_id(name)

    sql = "select avg(tokens) from game_results gr, game_results_players gp "
    sql += "where gr.id=gp.game_results_id and gr.winnerid = ? and gp.player_id= ? "
    sql += "ORDER BY gr.completed_date DESC"

    if(number_of_records != nil)
      sql += " LIMIT #{limit_start}, #{number_of_records}"
    end

    result = get_single_row_field(sql, 0, id, id)

    result
  end

  #Returns the number of average tokens for the given player
  #
  #Not required
  #limit_start is where the index should start
  #number_of_records is the number of records to pull maximum(from most recently won)
  def get_avg_tokens(name, limit_start = 0, number_of_records = nil)
    id = get_player_id(name)

    sql = "select avg(tokens) from game_results gr, game_results_players gp "
    sql += "where gr.id=gp.game_results_id and gp.player_id= ? "
    sql += "ORDER BY gr.completed_date DESC"

    if(number_of_records != nil)
      sql += " LIMIT #{limit_start}, #{number_of_records}"
    end

    result = get_single_row_field(sql, 0, id)

    result
  end

  #players_who_can_restore: [player1, player 2,....]
  #
  # Name associated to game, players (human) who can restore game, data to save
  #
  #
  # Returns id of game
  def createGameID(game_name, players_who_can_restore, game_obj)
    game_id = addGame(game_name, game_obj)

    players_who_can_restore.each { |player|
      player_id = get_player_id(player)
      addRestorablePlayer(game_id, player_id)
    }

    game_id
  end

  
  # Updates game of given game_id with the given data
  #
  def updateGame(gameID, data)

    #assert game exists
    #assert game not complete

    sql = "UPDATE game "
    sql+= "SET data = ? "
    sql+= "WHERE id = ?"

    prep_stat = @dbh.prepare(sql)
    stmt = prep_stat.execute(data, gameID)

    result = gameID

    stmt.close()
    result
  end

  # Sets a game, with the given game_id, as complete
  #
  #
  def setGameComplete(gameID)

    #assert game exists
    #assert game not complete

    sql = "UPDATE game "
    sql+= "SET complete = 1 "
    sql+= "WHERE id = ?"

    prep_stat = @dbh.prepare(sql)
    stmt = prep_stat.execute(gameID)

    result = gameID

    stmt.close()
    result
  end

  #Retrieves the data from an incomplete game with a given game_id
  #
  #Returns data of provided game_id(must be incomplete)
  def retrieveIncompleteGameData(gameID)
    #assert game exists
    #assert game not complete

    sql = "SELECT data "
    sql += "FROM game "
    sql += "WHERE id = ?"

    result = get_single_row_field(sql, nil, gameID)

    result
  end

  # Retrieves a set of incomplete games in order of newest to oldest
  #
  #Returns: [[id,name],[id,name],...]
  def retrieveIncompleteGamesForPlayer(player_name, limit_start = 0, number_of_records = nil)
    id = get_player_id(player_name)

    result = []

    sql = "SELECT g.id, g.name from game g, game_restore_players gp "
    sql += "WHERE g.id = gp.game_id and g.complete = 0 and gp.player_id = ? "
    sql += "ORDER BY g.created DESC"

    if(number_of_records != nil)
      sql += " LIMIT #{limit_start}, #{number_of_records}"
    end

    prep_stat = @dbh.prepare(sql)
    stmt = prep_stat.execute(id)

    row_count = stmt.num_rows()

    if(row_count > 0)

      row_count.times() {
        row = stmt.fetch()
        result << row
      }

    end

    stmt.close()

    result

  end

  # stats_hash:
  # { GAME_ID => #, (required)
  #   WINNER => player1, (If not included - assumes draw)
  #   PLAYERS => { player1 => tokens_played, player2=>tokens_played,...}
  # }
  #
  #
  def saveStatistics(stats_hash)

    game_id = stats_hash["GAME_ID"]
    players = stats_hash["PLAYERS"]

    if(stats_hash.has_key?("WINNER"))
      winner_name = stats_hash["WINNER"]
      winner_id = get_player_id(winner_name)
    else
      winner_id = @@NOT_FOUND_ID
    end

    game_results_id = addGameResults(game_id, winner_id)

    players.each_pair do |name,tokens|
      player_id = get_player_id(name)
      addPlayerGameResults(game_results_id, player_id, tokens)
    end

    game_results_id
  end

  # Returns recent games in order lastest to oldest
  # [[game_name, w/l/d, tokens_played],[name, win/loss/draw, tokens_played]...]
  #
  #
  def getRecentGames(player_name, limit_start = 0, number_of_records = nil)
    id = get_player_id(player_name)

    result = []

    sql = "SELECT g.name, gr.winnerid, grp.tokens "
    sql += "from game g, game_results_players grp, game_results gr "
    sql += "WHERE g.id = gr.game_id and gr.id = grp.game_results_id and g.complete = 1 and grp.player_id = ? "
    sql += "ORDER BY g.created DESC"

    if(number_of_records != nil)
      sql += " LIMIT #{limit_start}, #{number_of_records}"
    end

    prep_stat = @dbh.prepare(sql)
    stmt = prep_stat.execute(id)

    row_count = stmt.num_rows()

    if(row_count > 0)

      row_count.times() {
        row = stmt.fetch()

        winner_id = row[1]

        if(winner_id == id)
          status = 'w'
        elsif(winner_id == @@NOT_FOUND_ID)
          status = 'd'
        else
          status = 'l'
        end

        result << [row[0], status, row[2]]
      }

    end

    stmt.close()

    result
  end

  ####################################
  ######   Private Methods     #######
  ####################################

  private

  # Adds game to database
  #
  # Returns identifier for game
  def addGame(game_name, data)
    sql = "INSERT INTO game "
    sql += "(name,data,complete, created) VALUES "
    sql += "(?,?,0,NOW())"

    result = insert_row(sql, game_name, data)

    result
  end

  #  Adds game result to db, and returns id
  def addGameResults(game_id, winner_id)
    sql = "INSERT INTO game_results "
    sql += "(game_id, winnerid, completed_date) "
    sql += "VALUES (?,?, NOW())"

    results = insert_row(sql, game_id, winner_id)

    results
  end

  #Assigns player as being able to restore the given game
  def addRestorablePlayer(game_id, player_id)
    sql = "INSERT INTO game_restore_players "
    sql += "(game_id,player_id) "
    sql += "VALUES (?,?)"

    result = insert_row(sql, game_id, player_id)

    result
  end

  #Add player as being associated to the game for results
  def addPlayerGameResults(game_results_id, player_id, tokens)
    sql = "INSERT INTO game_results_players "
    sql += "(game_results_id, player_id, tokens) "
    sql += "VALUES (?,?,?)"

    result = insert_row(sql, game_results_id, player_id, tokens)

    result
  end

  #Checks if the game exists
  def gameExist?(game_id)
    sql = "select id from game where id = ?"
    id = get_single_row_field(sql, @@NOT_FOUND_ID, game_id)

    if(id == @@NOT_FOUND_ID)
      result = false
    else
      result = true
    end

    result
  end

  #Checks if the game is complete
  def gameComplete?(game_id)
    #assert game exists

    sql = "SELECT complete "
    sql += "FROM game "
    sql += "WHERE id = ?"

    value = get_single_row_field(sql, nil, game_id)

    if(value == 1)
      result = true
    else
      result = false
    end

    result

  end

  #returns -1 if player doesn't exist, otherwise player id
  def player_exist?(name)

    sql = "select id from player where name = ?"
    result = get_single_row_field(sql, @@NOT_FOUND_ID, name)

    result
  end

  #Takes a given sql statement and retrieves that data from the first field
  # of the first row.
  def get_single_row_field(sql, empty_default, *args)

    prep_stat = @dbh.prepare(sql)
    stmt = prep_stat.execute(*args)

    result = nil

    if(stmt.num_rows() > 0)
      row = stmt.fetch()

      if(row.size > 0 && row[0]!= nil)
        result = row[0]
      end
    end

    if(result == nil)
      result = empty_default
    end

    stmt.close()

    result

  end

  #Creates a new player with the given name
  def player_create(name)

    sql = "INSERT INTO player(name) VALUES(?)"

    result = insert_row(sql, name)

    result
  end

  #Generic function to insert data into a table, and return the created id
  def insert_row(sql, *args)
    prep_stat = @dbh.prepare(sql)
    stmt = prep_stat.execute(*args)

    result = stmt.insert_id()

    stmt.close()
    result
  end

  #Start of an generic exception handler...
  def generic_exception_handler(*args, &block)
    begin
      yield
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")

      #gracefully clean up, possibly pass in things to be closed.

      raise
    end
  end

end

db = ServerDatabase.getInstance()
db2 = ServerDatabase.getInstance()

puts db.get_player_id("bob")
puts db2.get_player_id("BOB")
puts db.get_player_id("Bob")
puts db2.get_player_id("boB")
puts db.get_player_id("asdf")
puts db2.get_wins("asdf", 0, 10)

puts "---"
puts db.get_loses("boB")
puts db.get_avg_tokens_for_win("boB")
puts db.get_avg_tokens("boB")
puts "---"
puts db.get_avg_tokens_for_win("asdf")
puts db.get_avg_tokens("asdf")
puts "---"
puts db.get_avg_tokens_for_win("Bob")
puts db.get_avg_tokens("Bob")

puts db.get_wins("asdf", 0, 10)
puts db.get_loses("asdf", 0, 10)
puts db.get_draws("Bob")

id = db.createGameID("!@^&*", ["asdf", "BOB", "boB", "bob"], "DATAZ__").to_s

db.updateGame(id, "DATAZ_M0D2")

db.setGameComplete(id)

#puts db.retrieveIncompleteGamesForPlayer("asdf").to_s

puts db.getRecentGames("asdf").to_s
puts db.getRecentGames("BOB").to_s
puts db.getRecentGames("bob").to_s

game = { "GAME_ID" => id,
  "WINNER" => "asdf",
  "PLAYERS" => { "asdf"=>3, "BOB"=>3, "boB"=>4, "bob"=>2}}

db.saveStatistics(game)

db.close_connection()
db2.close_connection()