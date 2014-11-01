class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_user_details

  before_action :current_company_tracks, only: [:index, :create, :tracks_search]

  def index
    @tracks = @current_company_tracks.search(params[:q]).result.page(params[:page]).per(20)
  end

  def create
    @track = @current_company_tracks.build(track_params)
    if @track.save
      redirect_to tracks_path(company: current_company), notice: "Track #{ @track.name } is successfully created."
    else
      render action: :new
    end
  end

  def toggle_enabled
    @track.toggle!(:enabled)
  end

  def reviewers
    set_track
  end

  def assign_reviewer
    set_track
    @user = @track.add_reviewer(params[:track][:reviewer_id])
  end

  def tracks_search
    @tracks = @current_company_tracks.extract(params[:type], current_user).search(params[:q]).result.page(params[:page]).per(20)
    render action: :index
  end

  def remove_reviewer
    set_track
    @track.remove_reviewer(params[:format])
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :owner_id, :enabled, :reviewer_id)
    end

    def set_track
      @track = current_company_tracks.find_by(id: params[:id])
    end

    def current_company_tracks
      @current_company_tracks = current_company.tracks
    end

    def get_autocomplete_items(parameters)
      super(parameters).with_company(current_company.id)
    end
end
