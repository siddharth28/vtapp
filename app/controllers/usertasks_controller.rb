class UsertasksController < ResourceController

  def start
    # FIXED
    # FIXME : Use build instead of create
    @usertask.start!
    render :show
  end

  def submit
    # FIXED
    # FIXME : Never add validations in controller.
    if @usertask.submit_task(params[:usertask])
      redirect_to @usertask, notice: "Task #{ @usertask.task.title } is successfully submitted"
    else
      render :show
    end
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id, :url, :comment)
    end
end
