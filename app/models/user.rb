class User < ApplicationRecord
  has_secure_password

  has_many :accounts, foreign_key: :owner_id, dependent: :destroy
  has_many :account_observers, dependent: :destroy
  has_many :observed_accounts, through: :account_observers, source: :account

  attr_accessor :account_name

  before_validation :normalize_email

  enum :role, { owner: "owner", observer: "observer" }, default: "owner"

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: roles.keys }
  validates :account_name, presence: true, on: :create, unless: :observer?

  def accessible_accounts
    Account.where(id: accounts.select(:id))
      .or(Account.where(id: observed_accounts.select(:id)))
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
