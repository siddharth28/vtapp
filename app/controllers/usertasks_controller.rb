class UsertasksController < ResourceController

  before_action :build_url, :build_comment, only: :show
  helper_method :current_track

  def start
    # FIXED
    # FIXME : Use build instead of create
    @usertask.start!
    redirect_to @usertask
  end

  def restart
    @usertask.restart!
    redirect_to @usertask
  end

  def submit_url
    @url = @usertask.urls.find_or_create_by(name: params[:url][:name])
    if @url.save
      @url.touch
      @usertask.submit! unless @usertask.submitted?
      redirect_to @usertask, notice: "Task #{ @usertask.task.title } is successfully submitted"
    else
      build_comment
      render :show
    end
  end

  def submit_comment
    @comment = @usertask.comments.build(commenter: current_user, data: params[:comment][:data])
    if @comment.save
      redirect_to @usertask, notice: "Comment added"
    else
      build_url
      render :show
    end
  end

  def resubmit
    @usertask.submit! unless @usertask.submitted?
    @usertask.comments.create(commenter: current_user, data: Task::STATE[:resubmitted])
    redirect_to @usertask
  end

  def assign_to_me
    if @usertask.user == current_user
      redirect_to assigned_to_others_for_review_track_tasks_path(current_track), alert: "Cannot change the reviewer of your own task"
    else
      @usertask.update_attributes(reviewer: current_user)
      redirect_to assigned_to_others_for_review_track_tasks_path(current_track)
    end
  end

  def review_task
    if @usertask.submitted?
      if params[:task_status] == 'accept'
        @usertask.accept!
        @usertask.comments.create(data: params[:usertask][:comment] << 'Your exercise is accepted', commenter: current_user)
      elsif params[:task_status] == 'reject'
        @usertask.reject!
        @usertask.comments.create(data: params[:usertask][:comment] << 'Your exercise is rejected', commenter: current_user)
      end
    end
    redirect_to @usertask
  end

  private
    def usertask_params
      params.require(:usertask).permit(:user_id, :task_id, :url, :comment)
    end

    def build_url
      if @usertask.user == current_user
        @url = @usertask.urls.build
      end
    end

    def build_comment
      @comment = @usertask.comments.build
    end

    def current_track
      @track ||= @usertask.task.track
    end
end
