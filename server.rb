require "sinatra"
require "yaml"
require "logger"
require "json"
require_relative "./database"
require_relative "./mail_handler"

class Main < Sinatra::Base
  enable :logging

  get "/" do
    
  end

  post "/" do
    puts "hi"
    logger.info JSON.pretty_generate(params)
  end
end
