require "sinatra"
require_relative "./database"

get "/current_mood.json" do
  current_mood = Mood::Database.database[:moods].order(:id).last
  current_mood.to_json
end
