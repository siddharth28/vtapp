class TasksController < ResourceController
  include TheSortableTreeController::Rebuild

  before_filter :get_track
  skip_before_filter :receive_resource
  skip_load_resource only: [:create, :index, :new]

  autocomplete :task, :title
  autocomplete :user, :name, full: true, extra_data: [:email], display_value: :display_user_details

  def index
    @tasks = @track.tasks.includes(:actable).nested_set.all
  end

  def new
    @task = @track.tasks.build
    authorize! :manage, @task
  end

  def create
    if params[:task][:need_review] == '1'
      @exercise_task = ExerciseTask.new(task_params)
      @task = @exercise_task.task
      save_task(@exercise_task)
    else
      @task = Task.new(task_params)
      save_task(@task)
    end
  end

  def update
    if params[:task][:need_review] == '1'
      @exercise_task = @task.specific || ExerciseTask.new
      @exercise_task.task ||= @task
      update_task(@exercise_task)
    else
      @task.specific && @task.specific.destroy
      update_task(@task)
    end
  end

  def destroy
    @task.destroy
    redirect_to manage_track_tasks_path, notice: "Task #{ @task.title } is successfully deleted."
  end

  def manage
    @tasks = @track.tasks.nested_set.all
    authorize! :manage, @track
  end

  def sample_solution
    send_file @task.sample_solution.path
  end

  def remove_sample_solution
    @task.specific.sample_solution = nil
    @task.save
    redirect_to edit_track_task_path
  end

  rescue_from ActiveRecord::ActiveRecordError do |exception|
    if request.format == :js
      flash[:error] = exception.message
      render :rebuild
    end
  end

  private
    def get_track
      @track = Track.find(params[:track_id])
    end

    def task_params
      if params[:task][:need_review] == '1'
        params.require(:task).permit(:title, :description, :parent_id, :instructions, :reviewer_id, :is_hidden, :sample_solution).merge!(track: @track)
      else
        params.require(:task).permit(:title, :description, :parent_id).merge!(track: @track)
      end
    end

    def save_task(task)
      if task.save
        redirect_to manage_track_tasks_path, notice: "Task #{ task.title } is successfully created."
      else
        render action: 'new'
      end
    end

    def update_task(task)
      if task.update(task_params)
        redirect_to manage_track_tasks_path, notice: "Task #{ task.title } is successfully updated."
      else
        render action: 'edit'
      end
    end

    def get_autocomplete_items(parameters)
      if parameters[:method] == :name
        super(parameters).with_company(current_company).with_role(:track_reviewer, @track)
      elsif parameters[:method] == :title
        super(parameters).with_track(@track).with_no_parent
      end
    end
end
