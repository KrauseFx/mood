task :morning do
  require_relative "./mail_handler"
  Mood::MailHandler.send_question(
    subject: "🌆 How are you feeling this morning?"
  )
end

task :evening do
  require_relative "./mail_handler"
  Mood::MailHandler.send_question(
    subject: "🌃 How happy were you with today?"
  )
end
