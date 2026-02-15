class UsersController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_account
  before_action :ensure_public_signup_allowed!, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    ActiveRecord::Base.transaction do
      @user.save!
      account = @user.accounts.create!(name: @user.account_name)
      account.adopt_unscoped_records! if Account.count == 1

      reset_session
      session[:user_id] = @user.id
      session[:account_id] = account.id
    end

    redirect_to root_path, notice: "Your account is ready."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def ensure_public_signup_allowed!
    return if public_signup_allowed?

    head :not_found
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :account_name)
  end
end
