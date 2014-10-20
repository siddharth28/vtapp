class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_user_details

  def index
    company = set_company
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

  def toggle_enabled
    @track.toggle!(:enabled)
  end

  def reviewers
    @company, @track = set_data
  end

  def assign_reviewer
    company, @track = set_data
    @user = @track.add_reviewer(params[:track][:reviewer_id])
  end

  def remove_reviewer
    company, @track = set_data
    @track.remove_reviewer(params[:format])
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :owner_id, :enabled, :reviewer_id)
    end

    def set_company
      current_user.company
    end

    def set_track(company)
      company.tracks.find_by(id: params[:id])
    end

    def set_data
      company = set_company
      return company, set_track(company)
    end

    def get_autocomplete_items(parameters)
      super(parameters).where(company_id: current_user.company_id)
    end
end
