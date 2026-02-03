class SessionsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_account

  def new
  end

  def create
    user = User.find_by(email: session_params[:email].to_s.downcase)

    if user&.authenticate(session_params[:password])
      reset_session
      session[:user_id] = user.id
      account = user.accessible_accounts.order(:created_at).first
      session[:account_id] = account&.id

      if account
        redirect_to root_path, notice: "Welcome back!"
      else
        redirect_to new_account_path, notice: "Create your first timeline to continue."
      end
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Signed out."
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
