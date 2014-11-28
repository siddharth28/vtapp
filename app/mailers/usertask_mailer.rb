class UsertaskMailer < ActionMailer::Base
  default from: DEFAULT_EMAIL

  def exercise_review_email(usertask)
    @usertask = usertask
    mail(to: @usertask.user.email, subject: "Task status of #{ @usertask.task.title } is #{ @usertask.aasm_state }")
  end

end
