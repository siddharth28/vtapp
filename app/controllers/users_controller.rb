class UsersController < ApplicationController
  load_and_authorize_resource

  before_action :authenticate_user!
end
