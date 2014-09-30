class UsersController < ApplicationController
  load_and_authorize_resource
  ## FIXED
  ## FIXME_NISH Use before_action, instead of before_filter.
  before_action :authenticate_user!

  def index
    ## FIXED
    ## FIXME_NISH We don't need to fetch the companies, as load_and_authorize_resource resouce will do it for us.
  end

  def show
    ## FIXED
    ## FIXME_NISH Move this in a before_action.
    ## FIXED
    ## FIXME_NISH Don't use back, as it raises an exception if there is not back.
    ## FIXED
    ## FIXME_NISH Please do this by specifying right permissions in ability.rb.
  end

  def create
    ## FIXED
    ## FIXME_NISH We don't require the following 2 lines code, as we have already written its logic in models.
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
