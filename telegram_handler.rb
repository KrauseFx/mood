require_relative './database'
require 'telegram/bot'
require 'tempfile'
require 'gruff'

module Mood
  class TelegramHandler
    def self.send_question(message:)
      # See more: https://core.telegram.org/bots/api#replykeyboardmarkup
      answers =
        Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          one_time_keyboard: false,
          keyboard: [
            ["5: pumped, energized", "4: happy, excited"],
            ["3: good, alright", "2: down, worried"],
            ["1: Sad, unhappy", "0: Miserable, nervous"]
          ]
        )
      self.perform_with_bot do |bot|
        bot.api.send_message(
          chat_id: self.chat_id,
          text: message,
          reply_markup: answers
        )
      end
    end

    def self.listen
      self.perform_with_bot do |bot|
        bot.listen do |message|
          if message.text.to_s.to_i > 0 || message.text.to_s.strip.start_with?("0")
            # As 0 is also a valid value
            rating = message.text.to_i

            if rating >= 0 && rating <= 5
              Mood::Database.database[:moods].insert({
                time: Time.now,
                value: rating
              })
              bot.api.send_message(chat_id: message.chat.id, text: "Got it! It's marked in the books 📚")
            else
              bot.api.send_message(chat_id: message.chat.id, text: "Only values from 0 to 5 are allowed")
            end
          else
            self.handle_input(bot, message)
          end
        end
      end
    end

    def self.handle_input(bot, message)
      case message.text
        when "/stats"
          avg = Mood::Database.database[:moods].avg(:value).to_f.round(2)
          bot.api.send_message(chat_id: message.chat.id, text: "The average rate is: #{avg}")
        when "/graph"
          file = Tempfile.new("graph")
          file_path = "#{file.path}.png"
          moods = Mood::Database.database[:moods]

          g = Gruff::Line.new
          g.title = "Your mood"
          g.theme = {
            background_colors: %w(#eeeeee #eeeeee),
            background_direction: :top_bottom,
          }
          g.data(:mood, moods.collect { |m| m[:value] })
          g.write(file_path)

          bot.api.send_photo(
            chat_id: message.chat.id, 
            photo: Faraday::UploadIO.new(file_path, 'image/png')
          )
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Sorry, I don't understand what you're saying, #{message.from.first_name}")
        end
    end

    def self.chat_id
      ENV["TELEGRAM_CHAT_ID"]
    end

    def self.perform_with_bot
      # https://github.com/atipugin/telegram-bot-ruby
      yield self.client
    rescue => ex
      puts "error sending the telegram notification"
      puts ex
      puts ex.backtrace
    end

    def self.client
      return @client if @client
      raise "No Telegram token provided on `TELEGRAM_TOKEN`" if token.to_s.length == 0
      @client = ::Telegram::Bot::Client.new(token)
    end

    def self.token
      ENV["TELEGRAM_TOKEN"]
    end
  end
end
