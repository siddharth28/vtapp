class UsersController < ResourceController
  #FIXED
  #FIXME Write rspec of this line
  before_action :authenticate_user!
end
