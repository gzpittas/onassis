class EntryLocation < ApplicationRecord
  belongs_to :entry
  belongs_to :location

  validates :location_id, uniqueness: { scope: :entry_id }
end
