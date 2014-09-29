class UsersController < ApplicationController
  load_and_authorize_resource

  ## FIXME_NISH Use before_action, instead of before_filter.
  before_filter :authenticate_user!

  def index
    ## FIXME_NISH We don't need to fetch the companies, as load_and_authorize_resource resouce will do it for us.
    @users = User.all
  end

  def show
    ## FIXME_NISH Move this in a before_action.
    ## FIXME_NISH Don't use back, as it raises an exception if there is not back.
    ## FIXME_NISH Please do this by specifying right permissions in ability.rb.
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  def create
    ## FIXME_NISH We don't require the following 2 lines code, as we have already written its logic in models.
    defaults = { password: User.random_password }
    params[:user] = defaults.merge(user_params)
    @user = User.new(user_params)
    ## FIXED
    ## FIXME_NISH Use responds_to.
    responds_to do |format|
      if @user.save
        format.html { redirect_to login_path(@user), notice: "Dear #{@user.name}, you have been successfully registered. Please log in to continue" }
      else
        format.html { render action: :new }
      end
    end
  end

end
