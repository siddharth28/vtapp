class UsertasksController < ResourceController

  def start
    # FIXED
    # FIXME : Use build instead of create
    @usertask.start!
    render :show
  end

  def submit
    if @usertask.submit_task(params[:usertask])
      redirect_to @usertask, notice: "Task #{ @usertask.task.title } is successfully submitted"
    else
      render :show
    end
  end

  def assign_to_me
    @usertask.update_attributes(reviewer: current_user)
    redirect_to assigned_to_others_for_review_track_tasks_path(@usertask.task.track)
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id, :url, :comment)
    end
end
