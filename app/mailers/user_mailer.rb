class UserMailer < ApplicationMailer
  def account_activation(user)
    @user = user

    mail to: user.email, subject: (I18n.t 'account_authentication')
  end

  def self.send_activation_email(user)
    account_activation(user).deliver_now
  end
end
