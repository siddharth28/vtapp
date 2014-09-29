class UsersController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  def create
    defaults = { password: User.random_password }
    params[:user] = defaults.merge(user_params)
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path(@user), notice: "Dear #{@user.name}, you have been successfully registered. Please log in to continue"
    else
      render action: :new
    end
  end

  private
    def user_params
      params.require(:user).permit!    
    end

end
