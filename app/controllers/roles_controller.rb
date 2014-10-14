class RolesController < ApplicationController
  def home_page
    if current_user.has_role? :super_admin
      redirect_to companies_path
    elsif current_user.has_role? :account_owner
      redirect_to users_path
    end
  end
end
