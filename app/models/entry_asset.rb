class EntryAsset < ApplicationRecord
  belongs_to :entry
  belongs_to :asset

  validates :asset_id, uniqueness: { scope: :entry_id }
end
