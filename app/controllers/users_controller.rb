class UsersController < ApplicationController
  load_and_authorize_resource
  ## FIXED
  ## FIXME_NISH Use before_action, instead of before_filter.
  before_action :authenticate_user!

  def show
    ## FIXED
    ## FIXME_NISH Move this in a before_action.
    ## FIXED
    ## FIXME_NISH Don't use back, as it raises an exception if there is not back.
    ## FIXED
    ## FIXME_NISH Please do this by specifying right permissions in ability.rb.
  end

end
