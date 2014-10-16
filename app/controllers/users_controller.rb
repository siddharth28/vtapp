class UsersController < ResourceController
  skip_load_resource only: [:index, :create]
  before_action :authenticate_user!
  autocomplete :user, :name, full: true
  autocomplete :user, :department

  def index
    @search = current_user.company.users.search(params[:q])
    @users = @search.result.page(params[:page]).per(20)
  end

  def new
    @user.tracks.build
    @tracks = current_user.company.tracks
  end

  def create
    @user = current_user.company.users.build(user_params)
    if @user.save
      redirect_to @user, notice: "user #{ @user.name } is successfully created."
    else
      render action: 'new'
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "user #{ @user.name } is successfully updated."
    else
      render action: 'edit'
    end
  end

  private
    def user_params
      if current_user.has_role? :account_owner
        params.require(:user).permit(:name, :email, :department, :mentor_id, :admin, :enabled)
      elsif current_user.has_role? :admin
        params.require(:user).permit(:name, :email, :department, :mentor_id, :enabled)
      end
    end
    def get_autocomplete_items(parameters)
      super(parameters).where(company_id: current_user.company_id).group(:department)
    end
end
