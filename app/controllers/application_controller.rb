class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  #SEE Issue https://github.com/ryanb/cancan/issues/835
  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
end
