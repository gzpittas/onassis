class Music < ApplicationRecord
  validates :title, presence: true

  GENRES = %w[
    classical
    jazz
    pop
    rock
    folk
    greek
    opera
    orchestral
    soundtrack
    other
  ].freeze

  ERAS = %w[
    1920s
    1930s
    1940s
    1950s
    1960s
    1970s
    1980s
    timeless
  ].freeze

  MOODS = %w[
    romantic
    dramatic
    melancholic
    celebratory
    tense
    nostalgic
    triumphant
    mysterious
    peaceful
    energetic
  ].freeze

  USAGE_TYPES = %w[
    background
    montage
    diegetic
    theme
    opening
    closing
    transition
    source
  ].freeze

  validates :genre, inclusion: { in: GENRES }, allow_blank: true
  validates :era, inclusion: { in: ERAS }, allow_blank: true
  validates :mood, inclusion: { in: MOODS }, allow_blank: true
  validates :usage_type, inclusion: { in: USAGE_TYPES }, allow_blank: true

  scope :by_title, -> { order(:title) }
  scope :by_artist, -> { order(:artist, :title) }
  scope :by_genre, ->(genre) { where(genre: genre) if genre.present? }
  scope :by_mood, ->(mood) { where(mood: mood) if mood.present? }
  scope :by_era, ->(era) { where(era: era) if era.present? }

  def display_name
    if artist.present?
      "#{title} - #{artist}"
    else
      title
    end
  end

  def has_player?
    spotify_url.present? || youtube_url.present?
  end

  # Extract Spotify track/album/playlist ID from URL
  # Supports URLs like:
  # - https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh
  # - https://open.spotify.com/album/1DFixLWuPkv3KT3TnV35m3
  # - https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M
  def spotify_embed_url
    return nil unless spotify_url.present?

    # Match Spotify URLs
    if spotify_url =~ %r{open\.spotify\.com/(track|album|playlist)/([a-zA-Z0-9]+)}
      type = $1
      id = $2
      "https://open.spotify.com/embed/#{type}/#{id}?utm_source=generator&theme=0"
    else
      nil
    end
  end

  def spotify_type
    return nil unless spotify_url.present?

    if spotify_url =~ %r{open\.spotify\.com/(track|album|playlist)/}
      $1
    else
      nil
    end
  end

  # Extract YouTube video ID from URL
  # Supports URLs like:
  # - https://www.youtube.com/watch?v=dQw4w9WgXcQ
  # - https://youtu.be/dQw4w9WgXcQ
  def youtube_embed_url
    return nil unless youtube_url.present?

    video_id = nil

    if youtube_url =~ /youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)/
      video_id = $1
    elsif youtube_url =~ /youtu\.be\/([a-zA-Z0-9_-]+)/
      video_id = $1
    end

    video_id ? "https://www.youtube.com/embed/#{video_id}" : nil
  end
end
