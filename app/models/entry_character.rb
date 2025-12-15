class EntryCharacter < ApplicationRecord
  belongs_to :entry
  belongs_to :character
end
