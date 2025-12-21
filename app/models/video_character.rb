class VideoCharacter < ApplicationRecord
  belongs_to :video
  belongs_to :character
end
