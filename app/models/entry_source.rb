class EntrySource < ApplicationRecord
  belongs_to :entry
  belongs_to :source

  validates :source_id, uniqueness: { scope: :entry_id, message: "has already been added to this entry" }
end
