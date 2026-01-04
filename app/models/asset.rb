class Asset < ApplicationRecord
  include AccountScoped

  has_many :entry_assets, dependent: :destroy
  has_many :entries, through: :entry_assets
  has_many :asset_images, dependent: :destroy
  has_many :images, through: :asset_images
  has_many :video_assets, dependent: :destroy
  has_many :videos, through: :video_assets
  belongs_to :featured_image, class_name: "Image", optional: true

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

  DATE_PRECISIONS = %w[exact month year decade approximate].freeze

  validates :acquisition_date_precision, inclusion: { in: DATE_PRECISIONS }, allow_blank: true

  def display_name
    name
  end

  def type_display
    asset_type&.titleize || "Unspecified"
  end

  def ownership_period
    return nil unless acquisition_date
    if disposition_date.present?
      "#{acquisition_date_display} - #{disposition_date}"
    else
      "#{acquisition_date_display} - present"
    end
  end

  def acquisition_date_display
    return nil unless acquisition_date

    case acquisition_date_precision
    when 'decade'
      "#{(acquisition_date.year / 10) * 10}s"
    when 'year'
      acquisition_date.year.to_s
    when 'month'
      acquisition_date.strftime("%B %Y")
    when 'approximate'
      "c. #{acquisition_date.year}"
    else # exact or nil
      acquisition_date.strftime("%B %d, %Y")
    end
  end

  def card_image
    featured_image || images.first
  end
end
