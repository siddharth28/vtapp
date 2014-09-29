class UserMailer < ActionMailer::Base
  ## FIXME_NISH Please don't hardcode the email, move it in a constant.
  default from: "siddharthvinsol@gmail.com"

  def welcome_email(user_email, password)
    @user_email = user_email
    @password = password
    ## FXIME_NISH DOn't sue url like this, please use route helpers. Also, we don't need to restore it in @url.
    @url  = 'http://example.com/login'
    mail(to: @user_email, subject: 'Welcome to My Awesome Site')
  end

  ## FIXME_NISH Remove commented code.
  # handle_asynchronously :welcome_email
end
