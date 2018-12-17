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
                time: Time.at(message.date),
                value: rating
              })
              bot.api.send_message(chat_id: message.chat.id, text: "Got it! It's marked in the books 📚")

              if rating <= 1
                bot.api.send_message(chat_id: message.chat.id, text: "Feeling down sometimes is okay. Maybe take 2 minutes to reflect on why you're not feeling better, and optionally add a /note")
                bot.api.send_message(chat_id: message.chat.id, text: "Sending hugs 🤗🤗🤗")
              end

              if rating == 5
                bot.api.send_message(chat_id: message.chat.id, text: "💫 Awesome to hear, maybe take 2 minutes to reflect on why you're feeling great, and optionally add a /note")
              end
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
      # This is for all the trolls that add the bot to some group conversations
      # or try to text your bot
      if message.chat.id.to_s != self.chat_id.to_s
        puts "Chat ID #{message.chat.id} doesn't match the provided Chat ID #{self.chat_idgit}"
        return
      end

      case message.text
        when "/stats"
          avg = Mood::Database.database[:moods].avg(:value).to_f.round(2)
          total_moods = Mood::Database.database[:moods].count
          first_mood = Mood::Database.database[:moods].first[:time]
          number_of_months = (Time.now - first_mood) / 60.0 / 60.0 / 24.0 / 30.0
          average_number_of_moods = (total_moods / number_of_months) / 30.0

          bot.api.send_message(chat_id: message.chat.id, text: "The average mood is: #{avg}")
          bot.api.send_message(chat_id: message.chat.id, text: "Total tracked moods: #{total_moods}")
          bot.api.send_message(chat_id: message.chat.id, text: "Number of months tracked: #{number_of_months.round(1)}")
          bot.api.send_message(chat_id: message.chat.id, text: "Averaging #{average_number_of_moods.round(1)} per day")
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
        when "/notes"
          Mood::Database.database[:notes].each do |n|
            bot.api.send_message(chat_id: message.chat.id, text: "#{n[:time].strftime("%Y-%m-%d")}: #{n[:note]}")
          end
        when /\/note\ /
          note_content = message.text.split("/note ").last
          Mood::Database.database[:notes].insert({
            time: Time.at(message.date),
            note: note_content
          })
          bot.api.send_message(chat_id: message.chat.id, text: "Got it! I'll forever remember this note for you 📚")
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
