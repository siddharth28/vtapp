class RolesController < ApplicationController
  def home_page
    #FIXME : create dynamic method for super_admin?
    if current_user.has_role? :super_admin
      redirect_to companies_path
    #FIXME : create dynamic method for account_owner?
    elsif current_user.has_role? :account_owner, :any
      redirect_to users_path
    end
  end
end
