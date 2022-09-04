class ApplicationMailer < ActionMailer::Base
  APP_MAIL_ADDRESS = 'el.task.management@gmail.com'.freeze

  default from: APP_MAIL_ADDRESS
  layout 'mailer'
end
