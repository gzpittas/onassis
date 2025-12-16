class Character < ApplicationRecord
  has_many :entry_characters, dependent: :destroy
  has_many :entries, through: :entry_characters
  has_many :character_links, dependent: :destroy

  accepts_nested_attributes_for :character_links, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true

  RELATIONSHIPS = %w[family business romantic political social rival employee other].freeze

  validates :relationship, inclusion: { in: RELATIONSHIPS }, allow_blank: true

  scope :family, -> { where(relationship: "family") }
  scope :business, -> { where(relationship: "business") }
  scope :romantic, -> { where(relationship: "romantic") }
  scope :by_name, -> { order(:name) }
  scope :lead, -> { where(lead_character: true) }

  def lifespan
    return nil unless birth_date
    death_date ? "#{birth_date.year}–#{death_date.year}" : "#{birth_date.year}–"
  end

  def age_at(date)
    return nil unless birth_date && date
    age = date.year - birth_date.year
    age -= 1 if date < birth_date + age.years
    age
  end
end
