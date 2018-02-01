require "sinatra"
require "yaml"
require "logger"
require "json"
require_relative "./database"
require_relative "./mail_handler"

enable :logging

get "/" do
  db = Mood::Database.database
  @moods = db[:moods]
  erb :index
end

post "/" do
  puts "hi"
  logger.info JSON.pretty_generate(params)

  # rating = 8 # TODO: replace with actual rating
  db = Mood::Database.database
  db[:moods].insert({
    time: Time.now,
    value: rating
  })
end
