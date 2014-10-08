class UsersController < ResourceController
  #FIXME Write rspec of this line
  before_action :authenticate_user!
end
