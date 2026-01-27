class MembersController < ApplicationController
  before_action :require_write_access

  def index
    @memberships = current_account.account_observers
      .includes(:user)
      .joins(:user)
      .order("users.email")
    @member = User.new
  end

  def create
    @memberships = current_account.account_observers
      .includes(:user)
      .joins(:user)
      .order("users.email")
    email = member_params[:email].to_s.downcase.strip

    if email.blank?
      @member = User.new
      @member.errors.add(:email, "can't be blank")
      return render :index, status: :unprocessable_entity
    end

    user = User.find_by(email: email)

    if user
      if current_account.observers.exists?(id: user.id)
        @member = User.new(email: email)
        @member.errors.add(:email, "already has access")
        return render :index, status: :unprocessable_entity
      end

      current_account.account_observers.create!(user: user)
      redirect_to members_path, notice: "#{email} now has observer access."
    else
      @member = User.new(
        email: email,
        role: "observer",
        password: member_params[:password],
        password_confirmation: member_params[:password_confirmation]
      )

      if @member.password.blank?
        @member.errors.add(:password, "can't be blank")
        return render :index, status: :unprocessable_entity
      end

      if @member.save
        current_account.account_observers.create!(user: @member)
        redirect_to members_path, notice: "#{email} invited as observer."
      else
        render :index, status: :unprocessable_entity
      end
    end
  end

  private

  def member_params
    params.require(:member).permit(:email, :password, :password_confirmation)
  end
end
