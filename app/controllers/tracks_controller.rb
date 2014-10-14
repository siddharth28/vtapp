class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_user_details

  def index
    # company = Company.find_by(id: params[:company])
    # @tracks = company.tracks
    render nothing: true
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

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :owner_name, :owner_email, :enabled)
    end

    def get_autocomplete_items(parameters)
      super(parameters).where(company_id: current_user.company_id)
    end
end
