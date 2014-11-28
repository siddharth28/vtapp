class RolesController < ApplicationController

  def home_page
    ## FIXME_NISH Rather than this we can create a method home_path which calls the route_helper rahter than redirect,
    ## and wherever we can use it like redirect_to home_path.
    if current_user.super_admin?
      redirect_to companies_path
    elsif current_user.account_owner? || current_user.account_admin?
      redirect_to users_path
    else
      redirect_to user_path(current_user)
    end
  end
end
