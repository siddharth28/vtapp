class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_user_details

  def index
    @search = current_company.tracks.search(params[:q])
    @tracks = @search.result.page(params[:page]).per(20)
  end

  def create
    @track = current_company.tracks.build(track_params)
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

  def remove_reviewer
    set_track
    @track.remove_reviewer(params[:format])
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :owner_id, :enabled, :reviewer_id)
    end

    def set_track
      @track ||= current_company.tracks.find_by(id: params[:id])
    end

    def get_autocomplete_items(parameters)
      super(parameters).where(company_id: current_company.id)
    end
end
