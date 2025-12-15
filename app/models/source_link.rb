class SourceLink < ApplicationRecord
  belongs_to :source

  validates :url, presence: true
end
