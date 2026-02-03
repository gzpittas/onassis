class AccountsController < ApplicationController
  before_action :require_write_access
  skip_before_action :require_account, only: %i[new create]

  def index
    @accounts = current_user.accessible_accounts.order(:created_at)
  end

  def new
    unless current_user.can_create_timeline?
      redirect_to accounts_path, alert: "You've reached your timeline limit (#{current_user.max_timelines}). Contact us to add more."
      return
    end
    @account = current_user.accounts.new
  end

  def create
    unless current_user.can_create_timeline?
      redirect_to accounts_path, alert: "You've reached your timeline limit (#{current_user.max_timelines}). Contact us to add more."
      return
    end
    @account = current_user.accounts.new(account_params)

    if @account.save
      @account.adopt_unscoped_records! if Account.count == 1
      session[:account_id] = @account.id
      redirect_to root_path, notice: "Timeline created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def select
    account = current_user.accessible_accounts.find(params[:id])
    session[:account_id] = account.id
    redirect_to root_path, notice: "Switched to #{account.name}."
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end
end
