require 'telegram/bot'

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
          db = Mood::Database.database
          if message.text.to_i > 0 || message.text.strip.start_with?("0")
            # As 0 is also a valid value
            rating = message.text.to_i

            db[:moods].insert({
              time: Time.now,
              value: rating
            })
            bot.api.send_message(chat_id: message.chat.id, text: "Got it! It's marked in the books 📚")
          elsif message.text == "/stats"
            bot.api.send_message(chat_id: message.chat.id, text: "The average rate is: #{db[:moods].avg(:value).to_f}")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "Sorry, I don't understand what you're saying, #{message.from.first_name}")
          end
        end
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
