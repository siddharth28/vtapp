class TracksController < ResourceController
  autocomplete :user, :name, extra_data: [:email],  display_value: :display_track_owner_details

  def create
    @track = Track.new(track_params)
    if @track.save
      redirect_to @track, notice: "Track #{ @track.name } is successfully created."
    else
      render action: 'new'
    end
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :enabled, :track_owner)
    end
end
