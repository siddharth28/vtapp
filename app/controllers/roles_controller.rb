class RolesController < ApplicationController

  def home_page
    #FIXME : create dynamic method for super_admin?
    # if current_user.super_admin?
    #   redirect_to companies_path
    # #FIXME : create dynamic method for account_owner?
    # elsif current_user.account_owner? || current_user.account_admin?
    #   redirect_to users_path
    # end
    render html: "<strong>Not Found</strong>".html_safe
  end
end
