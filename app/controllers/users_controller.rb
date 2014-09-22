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
end
