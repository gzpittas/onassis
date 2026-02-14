class Character < ApplicationRecord
  include AccountScoped

  has_many :entry_characters, dependent: :destroy
  has_many :entries, through: :entry_characters
  has_many :character_links, dependent: :destroy
  has_many :article_characters, dependent: :destroy
  has_many :articles, through: :article_characters
  has_many :image_characters, dependent: :destroy
  has_many :images, through: :image_characters
  has_many :video_characters, dependent: :destroy
  has_many :videos, through: :video_characters
  has_many :casting_candidates, dependent: :destroy
  belongs_to :featured_image, class_name: "Image", optional: true

  accepts_nested_attributes_for :character_links, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true

  RELATIONSHIPS = %w[family business romantic political social rival employee other].freeze

  validates :relationship, inclusion: { in: RELATIONSHIPS }, allow_blank: true

  scope :family, -> { where(relationship: "family") }
  scope :business, -> { where(relationship: "business") }
  scope :romantic, -> { where(relationship: "romantic") }
  scope :by_name, -> { order(:name) }
  scope :lead, -> { where(lead_character: true) }

  def self.default_entry_character_ids
    default_entry_character_ids_for(Current.account)
  end

  def self.default_entry_character_ids_for(account)
    return [] unless account

    lead_scope = unscoped.where(account_id: account.id, lead_character: true)
    main = lead_scope
      .where("LOWER(name) LIKE ? AND LOWER(name) LIKE ?", "%aristotle%", "%onassis%")
      .order(:created_at, :id)
      .first

    main ||= lead_scope.order(:created_at, :id).first
    main ? [ main.id ] : []
  end

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

  def final_age
    return nil unless birth_date
    if death_date
      age_at(death_date)
    else
      age_at(Date.current)
    end
  end

  def age_label
    return nil unless final_age
    death_date ? "died at #{final_age}" : "age #{final_age}"
  end

  def card_image
    featured_image || images.first
  end
end
