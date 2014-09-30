class UserMailer < ActionMailer::Base
  DEFAULT_EMAIL = "siddharthvinsol@gmail.com"
  #FIXED 
  ## FIXME_NISH Please don't hardcode the email, move it in a constant.
  default from: DEFAULT_EMAIL

  def welcome_email(email, password)
    @user_email = email
    @password = password
    #FIXED 
    ## FXIME_NISH DOn't sue url like this, please use route helpers. Also, we don't need to restore it in @url.
    mail(to: @user_email, subject: 'Welcome to My Awesome Site')
  end
  #FIXED 
  ## FIXME_NISH Remove commented code.
end
