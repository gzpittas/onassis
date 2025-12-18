class AssetImage < ApplicationRecord
  belongs_to :asset
  belongs_to :image

  validates :image_id, uniqueness: { scope: :asset_id }
end
