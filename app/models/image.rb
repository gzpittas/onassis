require "net/http"
require "openssl"

class Image < ApplicationRecord
  has_one_attached :file

  has_many :entry_images, dependent: :destroy
  has_many :entries, through: :entry_images
  has_many :image_characters, dependent: :destroy
  has_many :characters, through: :image_characters

  validates :file, presence: true, unless: :importing_from_url?

  attr_accessor :remote_url

  def attach_from_url(url)
    return false if url.blank?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (compatible; OnassisTimeline/1.0)"
    response = http.request(request)

    # Handle redirects
    if response.is_a?(Net::HTTPRedirection)
      redirect_url = response["location"]
      return attach_from_url(redirect_url) if redirect_url.present?
    end

    return false unless response.is_a?(Net::HTTPSuccess)

    content_type = response["Content-Type"]&.split(";")&.first
    return false unless content_type&.start_with?("image/")

    extension = case content_type
    when /jpeg/ then ".jpg"
    when /png/ then ".png"
    when /gif/ then ".gif"
    when /webp/ then ".webp"
    else ".jpg"
    end

    filename = File.basename(uri.path).presence || "imported_image#{extension}"
    filename = "#{filename}#{extension}" unless filename.match?(/\.(jpg|jpeg|png|gif|webp)$/i)

    file.attach(
      io: StringIO.new(response.body),
      filename: filename,
      content_type: content_type
    )

    self.source_url = url
    true
  rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
         Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => e
    errors.add(:remote_url, "could not be fetched: #{e.message}")
    false
  end

  scope :by_date, -> { order(taken_date: :asc) }
  scope :by_date_desc, -> { order(taken_date: :desc) }
  scope :recent_first, -> { order(created_at: :desc) }

  def display_title
    title.presence || "Untitled image"
  end

  def date_display
    taken_date&.strftime("%B %d, %Y") || "Date unknown"
  end

  private

  def importing_from_url?
    remote_url.present? && !file.attached?
  end
end
