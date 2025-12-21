class Video < ApplicationRecord
  has_many :video_entries, dependent: :destroy
  has_many :entries, through: :video_entries
  has_many :video_characters, dependent: :destroy
  has_many :characters, through: :video_characters
  has_many :video_assets, dependent: :destroy
  has_many :assets, through: :video_assets
  has_many :video_locations, dependent: :destroy
  has_many :locations, through: :video_locations

  validates :title, presence: true

  VIDEO_TYPES = %w[
    documentary
    interview
    news
    footage
    film
    short
    lecture
    podcast
    archival
    trailer
    other
  ].freeze

  validates :video_type, inclusion: { in: VIDEO_TYPES }, allow_blank: true

  scope :by_title, -> { order(:title) }
  scope :by_date, -> { order(publication_date: :desc) }
  scope :by_type, ->(type) { where(video_type: type) if type.present? }
  scope :recent_first, -> { order(created_at: :desc) }

  def display_name
    title
  end

  def has_player?
    youtube_url.present? || vimeo_url.present?
  end

  # Extract YouTube video ID from URL
  def youtube_video_id
    return nil unless youtube_url.present?

    if youtube_url =~ /youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)/
      $1
    elsif youtube_url =~ /youtu\.be\/([a-zA-Z0-9_-]+)/
      $1
    elsif youtube_url =~ /youtube\.com\/embed\/([a-zA-Z0-9_-]+)/
      $1
    else
      nil
    end
  end

  def youtube_embed_url
    video_id = youtube_video_id
    video_id ? "https://www.youtube.com/embed/#{video_id}" : nil
  end

  def youtube_thumbnail_url
    video_id = youtube_video_id
    video_id ? "https://img.youtube.com/vi/#{video_id}/mqdefault.jpg" : nil
  end

  # Extract Vimeo video ID from URL
  def vimeo_video_id
    return nil unless vimeo_url.present?

    if vimeo_url =~ /vimeo\.com\/(\d+)/
      $1
    else
      nil
    end
  end

  def vimeo_embed_url
    video_id = vimeo_video_id
    video_id ? "https://player.vimeo.com/video/#{video_id}" : nil
  end

  def type_display
    video_type&.titleize || "Video"
  end

  def date_display
    publication_date&.strftime("%B %d, %Y") || "Date unknown"
  end
end
