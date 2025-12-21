class Location < ApplicationRecord
  has_many :entry_locations, dependent: :destroy
  has_many :entries, through: :entry_locations
  has_many :image_locations, dependent: :destroy
  has_many :images, through: :image_locations
  has_many :video_locations, dependent: :destroy
  has_many :videos, through: :video_locations
  belongs_to :featured_image, class_name: "Image", optional: true

  validates :name, presence: true

  scope :by_name, -> { order(name: :asc) }
  scope :by_type, ->(type) { where(location_type: type) if type.present? }
  scope :by_country, ->(country) { where(country: country) if country.present? }

  LOCATION_TYPES = %w[
    aircraft
    airport
    building
    city
    continent
    country
    embassy
    estate
    harbor
    hospital
    hotel
    island
    neighborhood
    office
    port
    region
    residence
    restaurant
    room
    vessel
    villa
  ].freeze

  def display_name
    name
  end

  # Build a full location string from available fields
  def full_location
    parts = []
    parts << room if room.present?
    parts << building if building.present?
    parts << address if address.present?
    parts << neighborhood if neighborhood.present?
    parts << city if city.present?
    parts << region if region.present?
    parts << country if country.present?
    parts << continent if continent.present?
    parts.join(", ")
  end

  # Short display for tags/lists
  def short_location
    if city.present? && country.present?
      "#{city}, #{country}"
    elsif city.present?
      city
    elsif country.present?
      country
    else
      name
    end
  end

  def type_display
    location_type&.titleize || "Unspecified"
  end

  def card_image
    featured_image || images.first
  end
end
