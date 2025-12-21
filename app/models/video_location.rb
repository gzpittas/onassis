class VideoLocation < ApplicationRecord
  belongs_to :video
  belongs_to :location
end
