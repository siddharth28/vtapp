class UsersController < ResourceController
  before_action :authenticate_user!
end
