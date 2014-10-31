class UsertasksController < ResourceController

  def start_task
    @usertask = current_user.usertasks.create(usertask_params)
    redirect_to action: :task_description, id: @usertask
  end

  def submit_task
    @usertask.submit_task(params[:usertask])
    redirect_to action: :task_description, id: params[:id]
  end

  def task_description
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id, :url, :comment)
    end
end
