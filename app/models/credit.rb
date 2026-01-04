class Credit < ApplicationRecord
  include AccountScoped

  has_many :credit_candidates, dependent: :destroy

  validates :title, presence: true

  scope :by_priority, -> { order(priority: :asc, created_at: :asc) }
end
