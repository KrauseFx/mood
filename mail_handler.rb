module Mood
  class MailHandler
    require 'sendgrid-ruby'
    include SendGrid

    def self.send_question(subject:)
      from = Email.new(email: "mood@krausefx.com")
      to = Email.new(email: "krausefx@gmail.com")
      content = Content.new(
        type: "text/plain",
        value: "10: Excellent, excited & pumped - 0: Down & unhappy"
      )
      mail = Mail.new(from, subject, to, content)

      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      response = sg.client.mail._('send').post(request_body: mail.to_json)
      puts response.status_code
      puts response.body
      puts response.headers
    end
  end
end
