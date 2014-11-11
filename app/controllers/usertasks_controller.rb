class UsertasksController < ResourceController

  def start
    # FIXED
    # FIXME : Use build instead of create
    @usertask = current_user.usertasks.build(usertask_params)
    if @usertask.save
      redirect_to usertasks_description_path(id: @usertask), notice: "Task #{ @usertask.task.title } is successfully started"
    else
      render :description
    end
  end

  def submit
    # FIXED
    # FIXME : Never add validations in controller.
    if @usertask.submit_task(params[:usertask])
      redirect_to usertasks_description_path(id: @usertask), notice: "Task #{ @usertask.task.title } is successfully submitted"
    else
      render :description
    end
  end

  def description
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id, :url, :comment)
    end
end
