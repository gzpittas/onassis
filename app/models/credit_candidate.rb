class CreditCandidate < ApplicationRecord
  belongs_to :credit

  validates :person_name, presence: true

  scope :by_priority, -> { order(priority: :asc, created_at: :asc) }
end
