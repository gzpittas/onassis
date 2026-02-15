class User < ApplicationRecord
  has_secure_password

  has_many :accounts, foreign_key: :owner_id, dependent: :destroy
  has_many :account_memberships, dependent: :destroy
  has_many :member_accounts, through: :account_memberships, source: :account

  attr_accessor :account_name, :skip_account_setup

  before_validation :normalize_email

  enum :role, { owner: "owner", observer: "observer" }, default: "owner"

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: roles.keys }
  validates :account_name, presence: true, on: :create, unless: :skip_account_setup

  def can_create_timeline?
    accounts.count < max_timelines
  end

  def accessible_accounts
    Account.where(id: accounts.select(:id))
      .or(Account.where(id: member_accounts.select(:id)))
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
