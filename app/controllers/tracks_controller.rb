class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_user_details

  def index
    company =  set_company
    @search = company.tracks.search(params[:q])
    @tracks = @search.result.page(params[:page]).per(20)
  end

  def create
    company = set_company
    @track = company.tracks.build(track_params)
    if @track.save
      redirect_to tracks_path(company: company), notice: "Track #{ @track.name } is successfully created."
    else
      render action: :new
    end
  end

  def assign_track_reviewer
    @company, @track = set_data
  end

  def update
    company, @track =  set_data
    user = @track.add_reviewer(params[:track][:reviewer_id])
    render :assign_track_reviewer
  end

  def remove_reviewer
    company, @track =  set_data
    @track.remove_reviewer(params[:format])
    render :assign_track_reviewer
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :owner_id, :enabled, :reviewer_id)
    end

    def set_company
      current_user.company
    end

    def set_track
      @company.tracks.find_by(id: params[:id])
    end

    def set_data
      @company = set_company
      return @company, set_track
    end

    def get_autocomplete_items(parameters)
      #FIXME : create scope for company
      super(parameters).where(company_id: current_user.company_id)
    end
end
