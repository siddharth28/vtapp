class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "admin", password: "admin"
  protect_from_forgery with: :exception
end
