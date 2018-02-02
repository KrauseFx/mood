task :morning do
  require_relative "./telegram_handler"
  Mood::TelegramHandler.send_question(
    message: "🌆 How are you feeling this morning?"
  )
end

task :noon do
  require_relative "./telegram_handler"
  Mood::TelegramHandler.send_question(
    message: "🏙 How are you feeling today?"
  )
end

task :evening do
  require_relative "./telegram_handler"
  Mood::TelegramHandler.send_question(
    message: "🌃 How happy were you with today?"
  )
end
