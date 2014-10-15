class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_user_details

  def index
    company = Company.find_by(id: params[:company])
    @search = company.tracks.search(params[:q])
    @tracks = @search.result.page(params[:page]).per(20)
  end

  def create
    company = current_user.company
    @track = company.tracks.build(track_params)
    if @track.save
      redirect_to tracks_path(company: company), notice: "Track #{ @track.name } is successfully created."
    else
      render action: 'new'
    end
  end

  def assign_track_reviewer
    
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :owner_id, :enabled)
    end

    def get_autocomplete_items(parameters)
      super(parameters).where(company_id: current_user.company_id)
    end
end
