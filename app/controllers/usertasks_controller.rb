class UsertasksController < ResourceController

  before_action :build_url, :build_comment, only: :show
  before_action :load_comments, :load_urls, only: [:show, :submit_url, :submit_comment, :review, :review_exercise]
  before_action :redirect_if_assigning_own_task, only: :assign_to_me
  helper_method :current_track

  def start
    # FIXED
    # FIXME : Use build instead of create
    @usertask.not_started? && @usertask.start!
    redirect_to @usertask
  end

  def restart
    @usertask.restart? && @usertask.restart!
    redirect_to @usertask
  end

  def submit_url
    ## FIXME_NISH refactor this action.
    @url = @usertask.urls.find_or_initialize_by(url_params)
    if @url.save && submit_task_if_in_progress
      @url.add_submission_comment
      redirect_to @usertask, notice: "Task #{ @usertask.task.title } is successfully submitted"
    else
      build_comment
      render :show
    end
  end

  def submit_comment
    ## FIXME_NISH refactor this action!
    @comment = @usertask.comments.build(comment_params)
    if @comment.save
      redirect_to @usertask, notice: "Comment added"
    else
      build_url
      render :show
    end
  end

  def submit_task
    if submit_task_if_in_progress
      redirect_to @usertask, notice: "Task submitted successfully"
    else
      redirect_to @usertask, error: "Unable to submit the task"
    end
  end

  def resubmit
    if submit_task_if_in_progress
      @usertask.urls.order(submitted_at: :desc).first.add_submission_comment
      redirect_to @usertask, notice: "Task resubmitted successfully"
    else
      redirect_to @usertask, error: "Unable to resubmit the task"
    end
  end

  def assign_to_me
    ## FIXME_NISH use appt. name.
    ## FIXED
    ## FIXME_NISH move the verification part of usertask.user == current_user in a before_action
    @usertask.update_attributes(reviewer: current_user)
    redirect_to assigned_to_others_for_review_track_tasks_path(current_track)
  end

  def review_exercise
    ## FIXME_NISH refactor this action and use appt. name.
    @usertask.attributes = usertask_params
    if @usertask.review_exercise
      redirect_to @usertask
    else
      render :review
    end
  end

  private
    def usertask_params
      params.require(:usertask).permit(:comment, :task_status)
    end

    def build_url
      ## FIXME_NISH method name should specify everything about the method.
      if @usertask.user == current_user
        @url = Url.new
      end
    end

    def build_comment
      @comment = Comment.new
    end

    def load_comments
      @comments = @usertask.comments.order(:created_at).includes(:commenter).persisted
    end

    def load_urls
      @urls = @usertask.urls.order(submitted_at: :desc).persisted
    end

    def current_track
      @track ||= @usertask.task.track
    end

    def submit_task_if_in_progress
      @usertask.in_progress? && @usertask.submit!
      @usertask.submitted? || @usertask.completed?
    end

    def redirect_if_assigning_own_task
      if @usertask.user == current_user
        redirect_to assigned_to_others_for_review_track_tasks_path(current_track), alert: "Cannot change the reviewer of your own task"
      end
    end

    def comment_params
      params.require(:comment).permit(:data, :commenter).merge(commenter: current_user)
    end

    def url_params
      params.require(:url).permit(:name)
    end
end
