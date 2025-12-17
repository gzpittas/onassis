class EntryImage < ApplicationRecord
  belongs_to :entry
  belongs_to :image

  validates :image_id, uniqueness: { scope: :entry_id }
end
