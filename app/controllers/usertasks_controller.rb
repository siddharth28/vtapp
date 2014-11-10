class UsertasksController < ResourceController

  def start_task
    # FIXME : Use build instead of create
    @usertask = current_user.usertasks.create(usertask_params)
    redirect_to action: :task_description, id: @usertask
  end

  def submit_task
    # FIXME : Never add validations in controller.
    if @usertask.task.specific && params[:usertask][:url].blank? && params[:usertask][:comment].blank?
      @usertask.errors[:url] << 'Either url or comment needs to be present for submission'
      @usertask.errors[:comment] << 'Either url or comment needs to be present for submission'
      render action: :task_description
    else
      @usertask.submit_task(params[:usertask])
      redirect_to action: :task_description, id: @usertask
    end
  end

  def task_description
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id, :url, :comment)
    end
end
