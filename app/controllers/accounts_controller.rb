class AccountsController < ApplicationController
  before_action :require_write_access
  before_action :set_owned_account, only: %i[edit update]
  skip_before_action :require_account, only: %i[new create]

  def index
    @accounts = current_user.accessible_accounts.order(:created_at)
    @owned_account_ids = current_user.accounts.pluck(:id)
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

  def edit
    @characters = Character.unscoped.where(account_id: @account.id).order(:name)
  end

  def update
    @characters = Character.unscoped.where(account_id: @account.id).order(:name)

    if @account.update(account_params)
      redirect_to accounts_path, notice: "Timeline settings updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def select
    account = current_user.accessible_accounts.find(params[:id])
    session[:account_id] = account.id
    redirect_to root_path, notice: "Switched to #{account.name}."
  end

  private

  def set_owned_account
    @account = current_user.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :main_character_id)
  end
end
