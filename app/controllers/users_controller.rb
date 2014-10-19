class UsersController < ResourceController
  skip_load_resource only: [:index, :create]
  before_action :authenticate_user!
  autocomplete :user, :name, full: true
  autocomplete :user, :department

  def index
    @search = current_user.company.users.eager_load(:roles).search(params[:q])
    @users = @search.result.page(params[:page]).per(20)
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
    user_params[:track_ids] ||= []
    if @user.update(user_params)
      redirect_to @user, notice: "user #{ @user.name } is successfully updated."
    else
      render action: 'edit'
    end
  end

  private
    def user_params
      if current_user.has_role? :account_owner, :any
        params.require(:user).permit(:name, :email, :department, :mentor_id, :admin, :enabled, track_ids: [])
      elsif current_user.has_role? :admin, :any
        params.require(:user).permit(:name, :email, :department, :mentor_id, :enabled, track_ids: [])
      end
    end
    def get_autocomplete_items(parameters)
      super(parameters).where(company_id: current_user.company_id).group(:department)
    end
end
