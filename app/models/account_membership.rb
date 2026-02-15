class AccountMembership < ApplicationRecord
  belongs_to :account
  belongs_to :user

  enum :role, { observer: "observer", editor: "editor" }, default: "observer"

  validates :role, inclusion: { in: roles.keys }
  validates :user_id, uniqueness: { scope: :account_id }
end
