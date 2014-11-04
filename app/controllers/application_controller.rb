class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # FIXED
  # FIXME : this should be before_action
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :receive_resource

  helper_method :current_company

  # FIXED
  # FIXME : this should be above methods
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/', :alert => exception.message
  end

  def current_company
    @current_company ||= current_user.company
  end

  #SEE Issue https://github.com/ryanb/cancan/issues/835
  def receive_resource
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:account_update) do |user|
        user.permit(:name, :email, :password, :password_confirmation, :current_password)
      end
    end
end
