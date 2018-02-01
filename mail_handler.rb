module Mood
  class MailHandler
    require 'sendgrid-ruby'
    include SendGrid

    def self.send_question
      from = Email.new(email: "mood@krausefx.com")
      to = Email.new(email: "krausefx@gmail.com")
      subject = "How are you feeling today?"
      content = Content.new(
        type: "text/plain",
        value: "10: Excellent, excited and pumped\n0: Down, unhappy, not sure where to go"
      )
      mail = Mail.new(from, subject, to, content)

      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      response = sg.client.mail._('send').post(request_body: mail.to_json)
      puts response.status_code
      puts response.body
      puts response.headers
    end

    def self.receive_reply
      
    end
  end
end
