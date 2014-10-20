class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  #FIXME : Seperate methods for before action (do not use blocks unless required)
  #SEE Issue https://github.com/ryanb/cancan/issues/835
  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:name, :email, :password, :password_confirmation, :current_password)
      end
    end
end
