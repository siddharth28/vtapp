class UserMailer < ActionMailer::Base
  DEFAULT_EMAIL = "siddharthvinsol@gmail.com"

  default from: DEFAULT_EMAIL

  def welcome_email(email, password)
    @user_email = email
    @password = password
    mail(to: @user_email, subject: 'Your Vtapp login details')
  end
end
