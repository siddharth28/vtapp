class TasksController < ResourceController
  skip_load_resource only: [:index, :create]
  before_filter :get_track

  autocomplete :task, :title
  autocomplete :user, :name

  def get_track
    @track = Track.find(params[:track_id])
  end

  def index
    @tasks = @track.tasks
  end

  def new
    @task = @track.tasks.build
  end

  def create
  end

  private
    def task_params
      if params[:task][:need_review]
      params.require(:task).permit(:title,)
    end

end
