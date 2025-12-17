class Image < ApplicationRecord
  has_one_attached :file

  has_many :entry_images, dependent: :destroy
  has_many :entries, through: :entry_images
  has_many :image_characters, dependent: :destroy
  has_many :characters, through: :image_characters

  validates :file, presence: true

  scope :by_date, -> { order(taken_date: :asc) }
  scope :by_date_desc, -> { order(taken_date: :desc) }
  scope :recent_first, -> { order(created_at: :desc) }

  def display_title
    title.presence || "Untitled image"
  end

  def date_display
    taken_date&.strftime("%B %d, %Y") || "Date unknown"
  end
end
