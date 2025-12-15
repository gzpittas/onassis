class CharacterLink < ApplicationRecord
  belongs_to :character

  validates :url, presence: true
end
