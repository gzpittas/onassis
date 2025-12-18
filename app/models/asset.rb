class Asset < ApplicationRecord
  has_many :entry_assets, dependent: :destroy
  has_many :entries, through: :entry_assets
  has_many :asset_images, dependent: :destroy
  has_many :images, through: :asset_images

  validates :name, presence: true

  scope :by_name, -> { order(name: :asc) }
  scope :by_type, ->(type) { where(asset_type: type) if type.present? }

  ASSET_TYPES = %w[
    vehicle
    vessel
    aircraft
    residence
    building
    jewelry
    artwork
    document
    other
  ].freeze

  def display_name
    name
  end

  def type_display
    asset_type&.titleize || "Unspecified"
  end

  def ownership_period
    return nil unless acquisition_date
    if disposition_date.present?
      "#{acquisition_date.year} - #{disposition_date}"
    else
      "#{acquisition_date.year} - present"
    end
  end
end
