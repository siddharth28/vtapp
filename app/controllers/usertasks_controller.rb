class UsertasksController < ResourceController

  def create
    @usertask = current_user.usertasks.build(usertask_params)
    if @usertask.save
      redirect_to action: 'show', id: @usertask, task_id: @usertask.task_id
    else
      render action: :new
    end
  end

  def show
    @usertask = current_user.usertasks.find_by(task_id: params[:task_id])
  end

  def update
    @usertask.submit_task
    redirect_to action: 'show', id: @usertask, task_id: params[:task_id]
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id)
    end
end