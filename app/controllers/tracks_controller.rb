class TracksController < ResourceController
  autocomplete :user, :name, { full: true, extra_data: [:email] }

  def create
    #FIXME_AB: should always use scoping like company.tracks.build
    @track = Track.new(track_params)
    if @track.save
      redirect_to @track, notice: "Track #{ @track.name } is successfully created."
    else
      render action: 'new'
    end
  end

  def display
    "#{ self.name } \n #{ self.email }"
  end

  private
    def track_params
      params.require(:track).permit(:name, :description, :instructions, :references, :enabled)
    end
end
