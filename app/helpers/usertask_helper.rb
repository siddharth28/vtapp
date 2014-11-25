module UsertaskHelper
  def current_task
    @task ||= @usertask.task
  end

end