class Mailer
  
  def send_email(self)
    UserMailer.delay.welcome_email(self)
  end

end
