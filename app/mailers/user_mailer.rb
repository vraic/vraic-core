class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.two_factor_code.subject
  #
  def two_factor_code(user, token)
    @user = user
    @token = token
    mail to: user.email_address, subject: "Your 2FA Verification Code"
  end
end
