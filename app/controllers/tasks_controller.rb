class TasksController < ResourceController
  include TheSortableTreeController::Rebuild
  before_action :get_track
  skip_before_action :receive_resource
  skip_load_resource only: [:create, :index, :new]
  skip_authorize_resource only: [:index, :new, :manage]

  autocomplete :task, :title
  autocomplete :user, :name, full: true, extra_data: [:email], display_value: :display_details
  autocomplete :user, :email, full: true, extra_data: [:name], display_value: :display_details

  rescue_from ActiveRecord::ActiveRecordError do |exception|
    if request.format == :js
      flash[:error] = exception.message
      render :rebuild
    end
  end

  def index
    authorize! :read, @track
    @tasks = @track.tasks
    if @tasks.blank?
      flash.now[:alert] = "Track: #{ @track.name } has no tasks at this moment"
    else
      @tasks = @tasks.includes(:usertasks).where(usertasks: { user: current_user }).nested_set
    end
  end

  def new
    authorize! :manage, @track
    @task = @track.tasks.build
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

  # FIXME : Index and manage actions are almost same, follow DRY
  def manage
    authorize! :manage, @track
    @tasks = @track.tasks
    if @tasks.blank?
      flash.now[:alert] = "Track: #{ @track.name } has no tasks at this moment"
    else
      @tasks = @tasks.includes(:actable).nested_set.all
    end
  end

  def sample_solution
    send_file @task.sample_solution.path
  end

  def remove_sample_solution
    @task.specific.sample_solution = nil
    @task.save
    redirect_to edit_track_task_path
  end

  def assign_runner
    @task.usertasks.find_or_create_by(user_id: params[:runner_id])
  end

  def remove_runner
    @task.usertasks.find_by(user: params[:runner_id]).destroy
  end

  def to_review
    @tasks = @track.tasks.includes(usertasks: :user, usertasks: :reviewer).where(usertasks: { reviewer_id: current_user.id, aasm_state: 'submitted' })
  end

  def assigned_to_others_for_review
    @tasks = @track.tasks.includes(usertasks: :user).where.not(usertasks: { reviewer_id: current_user.id }).where(usertasks: { aasm_state: 'submitted' })
  end

  def list
    @tasks = @track.tasks.includes(:actable).nested_set.all
  end

  private
    def get_track
      @track = current_company.tracks.find_by(id: params[:track_id])
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
        super(parameters).with_company(current_company).with_role(Track::ROLES[:track_reviewer], @track)
      elsif parameters[:method] == :title
        super(parameters).with_track(@track).with_no_parent.study_tasks
      elsif parameters[:method] == :email
        super(parameters).with_company(current_company).with_role(Track::ROLES[:track_runner], @track)
      end
    end
end
