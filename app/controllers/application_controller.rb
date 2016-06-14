class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_if_banned
  before_action :store_current_location, unless: :devise_controller?
  before_action :safari_warning


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
  end

  def redirect_if_non_admin
    redirect_to root_path unless current_user.is_admin?
  end

  def safari_warning
    flash[:alert] = "Safari is working on web cam support. Until then, use chatben in Chrome or Firefox! <a href='https://www.google.com/search?q=safari+webrtc+support'>(Read More)</a>".html_safe if !browser.device.mobile? && browser.safari?
  end

  private

  def redirect_if_banned
    # redirect_to banned_url if current_user && current_user.banned?
  end

  # override the devise helper to store the current location so we can
  # redirect to it after loggin in or out. This override makes signing in
  # and signing up work automatically.
  def store_current_location
    store_location_for(:user, request.url)
  end
end
