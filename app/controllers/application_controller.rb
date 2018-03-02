class ApplicationController < ActionController::Base
  
  http_basic_authenticate_with(name: Rails.application.credentials.config[:http][:name], password: Rails.application.credentials.config[:http][:password]) if ACCESS_RESTRICTED
  
end
