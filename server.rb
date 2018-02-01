require "sinatra"
require "yaml"
require "logger"
require "json"
require_relative "./database"
require_relative "./mail_handler"

# Mood::MailHandler.send_question

class Main < Sinatra::Base
  enable :logging

  post "/" do
    puts "hi"
    logger.info JSON.pretty_generate(params)
  end
end
