class RolesController < ApplicationController

  def home_page
    #FIXED
    #FIXME : create dynamic method for super_admin?
    if current_user.super_admin?
      redirect_to companies_path
    #FIXED
    #FIXME : create dynamic method for account_owner?
    elsif current_user.account_owner? || current_user.account_admin?
      redirect_to users_path
    end
  end
end
