class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_details

  before_action :set_track, only: [:reviewers, :assign_reviewer, :remove_reviewer]

  def index
    ## FIXME_NISH You don't need to add a check here, you have added it in ability.rb, use accessible_by method for this.
    @tracks = load_tracks.includes(:owner).page(params[:page])
  end

  def create
    @track = current_company.tracks.build(track_params)
    if @track.save
      redirect_to tracks_path(company: current_company), notice: "Track #{ @track.name } is successfully created."
    else
      render action: :new
    end
  end

  def assign_reviewer
    @track.add_track_role(:track_reviewer, params[:track][:reviewer_id])
  end

  def remove_reviewer
    @track.remove_track_role(:track_reviewer, params[:format])
  end

  def runners
    ## FIXME_NISH runners and reviewers are same, just a difference of role. do you think we should make them in one action.
    @track_runners = current_company.users.with_role(:track_runner, @track)
  end

  def update
    if @track.update(track_params)
      ## FIXED
      ## FIXME_NISH Please do this operation in model through callbacks.
      redirect_to @track, notice: "Track #{ @track.name } is successfully updated."
    else
      render action: 'edit'
    end
  end

  def status
    user = current_company.users.find_by(id: params[:runner])
    @tasks = @track.tasks.includes(:usertasks).where(usertasks: { user: user }).nested_set
    render 'tasks/index'
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :owner_id, :enabled, :reviewer_id)
    end

    def set_track
      @track = current_company.tracks.find_by(id: params[:id])
    end

    def get_autocomplete_items(parameters)
      super(parameters).with_company(current_company)
    end

    def load_tracks
      if params[:type]
        current_company.tracks.with_role(params[:type], current_user)
      else
        current_user.account_owner? || current_user.account_admin? ? current_company.tracks : current_user.tracks
      end
    end

end
