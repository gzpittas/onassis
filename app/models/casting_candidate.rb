class CastingCandidate < ApplicationRecord
  belongs_to :character

  validates :actor_name, presence: true

  scope :by_priority, -> { order(priority: :asc, created_at: :asc) }
end
