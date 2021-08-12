class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:mails, :support)
  layout 'mailer'
end
