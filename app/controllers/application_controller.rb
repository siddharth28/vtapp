class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ##FIXME_NISH Please don't leave unnecessary blank lines.

  ## FIXME_NISH Please verify the scope of this method in devise and move it to that scope.
  def after_sign_in_path_for(resource_or_scope)
    companies_path
  end
end
