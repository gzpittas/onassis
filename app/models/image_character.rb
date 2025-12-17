class ImageCharacter < ApplicationRecord
  belongs_to :image
  belongs_to :character

  validates :character_id, uniqueness: { scope: :image_id }
end
