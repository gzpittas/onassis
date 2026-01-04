class User < ApplicationRecord
  has_secure_password

  has_many :accounts, foreign_key: :owner_id, dependent: :destroy

  attr_accessor :account_name

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :account_name, presence: true, on: :create

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end
end
