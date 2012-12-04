require_relative "../server/server_database"

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

id = db.create_game_id("!@^&*", ["asdf", "BOB", "boB", "bob"], "DATAZ__").to_s

db.update_game(id, "DATAZ_M0D2")

db.set_game_complete(id)

puts db.retrieve_incomplete_games_for_player("asdf").to_s

puts db.get_recent_games("asdf").to_s
puts db.get_recent_games("asdf",0,3).to_s
puts db.get_recent_games("asdf",1,3).to_s

puts db.get_recent_games("BOB").to_s
puts db.get_recent_games("bob").to_s

game = { "GAME_ID" => id,
  "WINNER" => "asdf",
  "PLAYERS" => { "asdf"=>3, "BOB"=>3, "boB"=>4, "bob"=>2}}

db.save_statistics(game)

puts "LEADER BOARD:\n"
puts db.get_leader_board().to_s

db.close_connection()
db2.close_connection()