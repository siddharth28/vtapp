class UsertasksController < ResourceController

  def start_task
    # FIXED
    # FIXME : Use build instead of create
    @usertask = current_user.usertasks.build(usertask_params)
    if @usertask.save
      redirect_to action: :task_description, id: @usertask, notice: "Task #{ @usertask.task.title } is successfully started"
    else
      render action: :task_description
    end
  end

  def submit_task
    # FIXED
    # FIXME : Never add validations in controller.
    if @usertask.submit_task(params[:usertask])
      redirect_to action: :task_description, id: @usertask, notice: "Task #{ @usertask.task.title } is successfully submitted"
    else
      render action: :task_description
    end
  end

  def task_description
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id, :url, :comment)
    end
end
