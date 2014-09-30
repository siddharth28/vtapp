class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  ## FIXED
  ## FIXME_NISH Please don't leave unnecessary blank lines.
  ## FIXED scope = public
  ## FIXME_NISH Please verify the scope of this method in devise and move it to that scope.
  def after_sign_in_path_for(resource_or_scope)
    companies_path
  end
end
