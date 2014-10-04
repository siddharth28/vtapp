class Mailer

  def self.send_email(user)
    email = user.email
    password = user.password
    UserMailer.delay.welcome_email(email, password)
  end

end
