class ApplicationController < ActionController::Base
  layout 'application'
  before_filter :authenticate_user!
  before_filter :change_password_if_needed
  
  helper_method :current_access_level

  def change_password_if_needed
    authenticate_user! unless user_signed_in?

    if current_user.requires_password_change?
      render "users/change_password"
    end
  end
  
  private 
  
  def current_access_level
    return current_user.access_level if current_user && current_user.access_level
    AccessLevel::User["guest"]
  end
end
