require "sinatra"
require "yaml"
require "logger"
require "json"
require_relative "./database"
require_relative "./telegram_handler"

enable :logging

get "/" do
  db = Mood::Database.database
  @moods = db[:moods]
  erb :index
end

Mood::TelegramHandler.listen
