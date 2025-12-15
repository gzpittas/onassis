class Character < ApplicationRecord
  has_many :entry_characters, dependent: :destroy
  has_many :entries, through: :entry_characters

  validates :name, presence: true

  RELATIONSHIPS = %w[family business romantic political social rival employee other].freeze

  validates :relationship, inclusion: { in: RELATIONSHIPS }, allow_blank: true

  scope :family, -> { where(relationship: "family") }
  scope :business, -> { where(relationship: "business") }
  scope :romantic, -> { where(relationship: "romantic") }
  scope :by_name, -> { order(:name) }

  def lifespan
    return nil unless birth_date
    death_date ? "#{birth_date.year}–#{death_date.year}" : "#{birth_date.year}–"
  end
end
