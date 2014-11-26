class UserMailer < ActionMailer::Base
  default from: DEFAULT_EMAIL

  def welcome_email(email, password)
    @user_email = email
    @password = password
    mail(to: @user_email, subject: 'Your Vtapp login details')
  end

  def exercise_review_email(usertask)
    @usertask = usertask
    mail(to: @usertask.user.email, subject: "Task status of #{ @usertask.task.title } is #{ @usertask.aasm_state }")
  end
end
