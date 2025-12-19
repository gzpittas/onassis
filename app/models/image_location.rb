class ImageLocation < ApplicationRecord
  belongs_to :image
  belongs_to :location

  validates :location_id, uniqueness: { scope: :image_id }
end
