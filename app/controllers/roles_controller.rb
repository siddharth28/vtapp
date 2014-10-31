class RolesController < ApplicationController

  def home_page
    if current_user.super_admin?
      redirect_to companies_path
    elsif current_user.account_owner? || current_user.account_admin?
      redirect_to users_path
    end
  end
end
