class UsersController < ResourceController
  skip_load_resource only: [:index, :create]
  before_action :authenticate_user!
  autocomplete :mentor, :name
  def show
  end
  def new
    @user = User.new
  end
  def create
    @user = current_user.company.users.build(user_params)
    if @user.save
      redirect_to @user, notice: "user #{ @user.name } is successfully created."
    else
      render action: 'new'
    end
  end
  def edit
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
      params.require(:user).permit(:name, :email, :department, :admin, :enabled)
    end
    def edit_user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
    end
end
