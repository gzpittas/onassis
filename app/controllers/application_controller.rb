class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current
  before_action :require_login
  before_action :require_account
  after_action { Current.reset }

  helper_method :current_user, :current_account, :signed_in?, :can_write?

  private

  def set_current
    Current.user = current_user
    Current.account = current_account
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_account
    return unless current_user

    accessible_accounts = current_user.accessible_accounts
    account = accessible_accounts.find_by(id: session[:account_id]) if session[:account_id]
    account ||= accessible_accounts.order(:created_at).first
    session[:account_id] = account.id if account
    account
  end

  def signed_in?
    current_user.present?
  end

  def require_login
    return if signed_in?

    redirect_to login_path, alert: "Please sign in to continue."
  end

  def require_account
    return unless signed_in?
    return if current_account.present?

    redirect_to new_account_path, alert: "Create a timeline to continue."
  end

  def can_write?
    return false unless current_user
    return true unless current_account

    current_account.owner_id == current_user.id
  end

  def require_write_access
    return if can_write?

    redirect_back(fallback_location: root_path, alert: "Read-only access.")
  end
end
