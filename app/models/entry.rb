class Entry < ApplicationRecord
  belongs_to :source, optional: true # Legacy - keeping for backward compatibility
  belongs_to :featured_image, class_name: "Image", optional: true
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

  # Returns the featured image or first associated image for display
  def card_image
    featured_image || images.first
  end

  accepts_nested_attributes_for :entry_sources, allow_destroy: true, reject_if: :all_blank

  before_validation :normalize_event_year
  before_validation :sync_event_parts_from_date

  validates :title, presence: true
  validate :require_event_date_or_year
  validate :event_year_not_zero
  validates :event_year, numericality: { only_integer: true }, allow_nil: true
  validates :event_month, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }, allow_nil: true
  validates :event_day, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }, allow_nil: true

  ENTRY_TYPES = %w[birth death marriage divorce business deal acquisition political travel scandal meeting speech party other].freeze
  DATE_PRECISIONS = %w[exact month year decade approximate].freeze

  validates :entry_type, inclusion: { in: ENTRY_TYPES }, allow_blank: true
  validates :date_precision, inclusion: { in: DATE_PRECISIONS }, allow_blank: true

  scope :chronological, -> { order(Arel.sql("event_year, COALESCE(event_month, 1), COALESCE(event_day, 1)")) }
  scope :reverse_chronological, -> { order(Arel.sql("event_year DESC, COALESCE(event_month, 1) DESC, COALESCE(event_day, 1) DESC")) }
  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }
  scope :by_type, ->(type) { where(entry_type: type) }
  scope :by_year, ->(year_param) do
    year_value = normalize_year_value(year_param)
    year_value ? where(event_year: year_value) : all
  end
  scope :by_decade, ->(decade_param) do
    decade_value = normalize_year_value(decade_param)
    if decade_value
      start_year, end_year = decade_range(decade_value)
      where(event_year: start_year..end_year)
    else
      all
    end
  end

  def date_display
    start_date = event_year_value&.negative? ? nil : event_date
    start_display = format_date_with_precision(start_date, year: event_year_value, month: event_month_value, day: event_day_value, era: event_era)
    if end_date.present? && end_date != event_date
      end_display = format_date_with_precision(end_date)
      [start_display, end_display].compact.join(" – ")
    else
      start_display
    end
  end

  def formatted_date(format = nil)
    year = event_year_value
    return nil unless year
    return date_display if year.negative?
    return event_date.strftime(format) if format.present? && event_date.present?

    date_display
  end

  def format_date_with_precision(date = nil, year: nil, month: nil, day: nil, era: "ce")
    year ||= date&.year
    month ||= date&.month
    day ||= date&.day
    return nil unless year

    era = era.to_s.downcase
    era = "bce" if era.empty? && year.negative?
    display_year = era == "bce" ? year.abs : year
    suffix = era == "bce" ? " BC" : ""

    case date_precision
    when 'decade'
      "#{(display_year / 10) * 10}s#{suffix}"
    when 'year'
      "#{display_year}#{suffix}"
    when 'month'
      month_name = month ? Date::MONTHNAMES[month] : nil
      month_name ? "#{month_name} #{display_year}#{suffix}" : "#{display_year}#{suffix}"
    when 'approximate'
      "c. #{display_year}#{suffix}"
    else # exact or nil
      if month && day
        "#{Date::MONTHNAMES[month]} #{day}, #{display_year}#{suffix}"
      elsif month
        "#{Date::MONTHNAMES[month]} #{display_year}#{suffix}"
      else
        "#{display_year}#{suffix}"
      end
    end
  end

  def event_year_value
    event_year || event_date&.year
  end

  def event_month_value
    return event_month if event_month.present?
    return nil if event_year_value&.negative?

    event_date&.month
  end

  def event_day_value
    return event_day if event_day.present?
    return nil if event_year_value&.negative?

    event_date&.day
  end

  def event_year_abs
    event_year_value&.abs
  end

  def event_era
    year = event_year_value
    return year.negative? ? "bce" : "ce" if year.present?

    @event_era.presence || "ce"
  end

  def event_era=(value)
    @event_era = value.to_s.downcase.presence
  end

  def event_decade_value
    year = event_year_value
    year ? self.class.decade_value_from_year(year) : nil
  end

  def event_decade_label
    decade = event_decade_value
    decade ? self.class.decade_label(decade) : nil
  end

  def sort_key
    year = event_year_value
    return nil unless year

    month = event_month_value || 1
    day = event_day_value || 1
    (year * 10000) + (month * 100) + day
  end

  def event_date_for_age
    year = event_year_value
    return nil unless year
    return nil if year.negative?

    return event_date if event_date.present?

    Date.new(year, event_month_value || 1, event_day_value || 1)
  end

  def year
    event_year_value
  end

  def self.normalize_year_value(value)
    return nil if value.blank?

    str = value.to_s.strip
    return nil if str.empty?

    if str.match?(/bc|bce/i)
      digits = str.scan(/\d+/).first
      digits ? -digits.to_i : nil
    else
      str.to_i
    end
  end

  def self.decade_range(decade_value)
    if decade_value.negative?
      [decade_value - 9, decade_value]
    else
      [decade_value, decade_value + 9]
    end
  end

  def self.decade_value_from_year(year)
    decade = (year.abs / 10) * 10
    year.negative? ? -decade : decade
  end

  def self.decade_label(decade_value)
    label = "#{decade_value.abs}s"
    decade_value.negative? ? "#{label} BC" : label
  end

  private

  def normalize_event_year
    return if event_year.blank?
    return unless @event_era.present?

    year = event_year.to_i.abs
    self.event_year = @event_era == "bce" ? -year : year
    if @event_era == "bce"
      had_date = event_date.present?
      self.event_date = nil
      if had_date
        self.event_month = nil
        self.event_day = nil
      end
    end
  end

  def sync_event_parts_from_date
    return unless event_date.present?
    return if event_year.present? && event_year.negative?

    self.event_year = event_date.year
    self.event_month = event_date.month
    self.event_day = event_date.day
  end

  def require_event_date_or_year
    return if event_year_value.present?

    errors.add(:event_date, "can't be blank")
  end

  def event_year_not_zero
    return if event_year.blank?

    errors.add(:event_year, "must be non-zero") if event_year.to_i.zero?
  end
end
