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
    @task = @track.tasks.build(:parent_id => params[:parent_id])
  end

  def create
    if params[:task][:need_review] == '0'
      @task = @track.tasks.build(task_params)
      if @task.save
        redirect_to [@track, @task], notice: "Task #{ @task.title } is successfully created."
      else
        render action: 'new'
      end
    elsif params[:task][:need_review] == '1'
      @exercise_task = ExerciseTask.new(task_params, track: @track)
      @task = @exercise_task.task
      if @exercise_task.save
        redirect_to [@track, @task], notice: "Task #{ @task.title } is successfully created."
      else
        render action: 'new'
      end
    end
  end

  def sort
    debugger;
    params[:task].sort { |a, b| a <=> b }.each_with_index do |id, index|
      value = id[1][:id]
      position = id[1][:position]
      position = position.to_i + 1
      parent = id[1][:parent_id]
      Task.update(value, :position => position, :parent_id => parent)
    end
    render :nothing => true
  end

  private
    def task_params
      if params[:task][:need_review] == '0'
        params.require(:task).permit(:title, :description, :parent_id, :need_review, :ancestry_depth)
      elsif params[:task][:need_review] == '1'
        params.require(:task).permit(:title, :description, :parent_id, :instructions, :reviewer_id, :is_hidden, :sample_solution, :need_review, :ancestry_depth)
      end
    end

end
