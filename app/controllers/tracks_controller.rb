class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_user_details

  before_action :set_track, only: [:reviewers, :assign_reviewer, :remove_reviewer]

  def index
    if current_user.account_owner? || current_user.account_admin?
      @tracks = current_company.tracks.load_with_owners.page(params[:page]).per(20)
    else
      @tracks = current_user.tracks.load_with_owners.page(params[:page]).per(20)
    end
  end

  def create
    @track = current_company.tracks.build(track_params)
    if @track.save
      redirect_to tracks_path(company: current_company), notice: "Track #{ @track.name } is successfully created."
    else
      render action: :new
    end
  end

  def reviewers
  end

  def assign_reviewer
    @track.add_track_role(:track_reviewer, params[:track][:reviewer_id])
  end

  def search
    @tracks = current_company.tracks.load_with_owners.extract(params[:type], current_user).search(params[:q]).result.page(params[:page]).per(20)
    render action: :index
  end

  def remove_reviewer
    @track.remove_track_role(:track_reviewer, params[:format])
  end

  def update
    if @track.update(track_params)
      @track.replace_owner(params[:track][:owner_id])
      redirect_to @track, notice: "Track #{ @track.name } is successfully updated."
    else
      render action: 'edit'
    end
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
end
