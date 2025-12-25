class Credit < ApplicationRecord
  has_many :credit_candidates, dependent: :destroy

  validates :title, presence: true

  scope :by_priority, -> { order(priority: :asc, created_at: :asc) }
end
