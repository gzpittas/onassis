class MembersController < ApplicationController
  before_action :require_account_owner

  def index
    load_memberships
    @member = User.new
  end

  def create
    load_memberships
    email = member_params[:email].to_s.downcase.strip
    role = member_params[:role].presence || "observer"

    if email.blank?
      @member = User.new
      @member.errors.add(:email, "can't be blank")
      return render :index, status: :unprocessable_entity
    end

    unless AccountMembership.roles.key?(role)
      @member = User.new(email: email)
      @member.errors.add(:role, "is invalid")
      return render :index, status: :unprocessable_entity
    end

    user = User.find_by(email: email)

    if user
      membership = current_account.account_memberships.find_or_initialize_by(user: user)

      if membership.persisted? && membership.role == role
        @member = User.new(email: email)
        @member.errors.add(:email, "already has access")
        return render :index, status: :unprocessable_entity
      end

      membership.role = role
      membership.save!

      if membership.saved_change_to_id?
        redirect_to members_path, notice: "#{email} now has #{role} access."
      else
        redirect_to members_path, notice: "#{email} access updated to #{role}."
      end
    else
      @member = User.new(
        email: email,
        password: member_params[:password],
        password_confirmation: member_params[:password_confirmation],
        skip_account_setup: true
      )

      if @member.password.blank?
        @member.errors.add(:password, "can't be blank")
        return render :index, status: :unprocessable_entity
      end

      if @member.save
        current_account.account_memberships.create!(user: @member, role: role)
        redirect_to members_path, notice: "#{email} invited as #{role}."
      else
        render :index, status: :unprocessable_entity
      end
    end
  end

  private

  def load_memberships
    @memberships = current_account.account_memberships
      .includes(:user)
      .joins(:user)
      .order("users.email")
  end

  def member_params
    params.require(:member).permit(:email, :role, :password, :password_confirmation)
  end
end
