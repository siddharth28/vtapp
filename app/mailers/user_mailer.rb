class UserMailer < ActionMailer::Base
  default from: "siddharthvinsol@gmail.com"

  def welcome_email(user_email, password)
    @user_email = user_email
    @password = password
    @url  = 'http://example.com/login'
    mail(to: @user_email, subject: 'Welcome to My Awesome Site')
  end
  # handle_asynchronously :welcome_email
end
