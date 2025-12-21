class Entry < ApplicationRecord
  belongs_to :source, optional: true # Legacy - keeping for backward compatibility
  has_many :entry_sources, dependent: :destroy
  has_many :sources, through: :entry_sources
  has_many :entry_characters, dependent: :destroy
  has_many :characters, through: :entry_characters
  has_many :entry_articles, dependent: :destroy
  has_many :articles, through: :entry_articles
  has_many :entry_images, dependent: :destroy
  has_many :images, through: :entry_images
  has_many :entry_assets, dependent: :destroy
  has_many :assets, through: :entry_assets
  has_many :entry_locations, dependent: :destroy
  has_many :locations, through: :entry_locations
  has_many :video_entries, dependent: :destroy
  has_many :videos, through: :video_entries

  accepts_nested_attributes_for :entry_sources, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :event_date, presence: true

  ENTRY_TYPES = %w[birth death marriage divorce business deal acquisition political travel scandal meeting speech party other].freeze
  DATE_PRECISIONS = %w[exact month year decade approximate].freeze

  validates :entry_type, inclusion: { in: ENTRY_TYPES }, allow_blank: true
  validates :date_precision, inclusion: { in: DATE_PRECISIONS }, allow_blank: true

  scope :chronological, -> { order(:event_date) }
  scope :reverse_chronological, -> { order(event_date: :desc) }
  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }
  scope :by_type, ->(type) { where(entry_type: type) }
  scope :by_year, ->(year) { where("strftime('%Y', event_date) = ?", year.to_s) }
  scope :by_decade, ->(decade) { where("event_date >= ? AND event_date < ?", Date.new(decade, 1, 1), Date.new(decade + 10, 1, 1)) }

  def date_display
    if end_date.present? && end_date != event_date
      "#{format_date_with_precision(event_date)} – #{format_date_with_precision(end_date)}"
    else
      format_date_with_precision(event_date)
    end
  end

  def format_date_with_precision(date)
    return nil unless date

    case date_precision
    when 'decade'
      "#{(date.year / 10) * 10}s"
    when 'year'
      date.year.to_s
    when 'month'
      date.strftime("%B %Y")
    when 'approximate'
      "c. #{date.year}"
    else # exact or nil
      date.strftime("%B %d, %Y")
    end
  end

  def year
    event_date&.year
  end
end
