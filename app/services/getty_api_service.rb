require "net/http"
require "json"

class GettyApiService
  API_BASE = "https://api.gettyimages.com/v3"

  class ApiError < StandardError; end

  def initialize
    @api_key = ENV["GETTY_API_KEY"]
    raise ApiError, "Getty API key not configured. Add GETTY_API_KEY to your .env file." unless @api_key.present?
  end

  # Extract image ID from various Getty URLs
  def self.extract_image_id(url)
    # Handle various Getty URL formats:
    # https://www.gettyimages.com/detail/news-photo/aristotle-onassis-news-photo/123456789
    # https://www.gettyimages.com/detail/123456789
    # https://media.gettyimages.com/id/123456789/photo/...
    # https://www.gettyimages.co.uk/detail/news-photo/...

    return nil unless url.match?(/gettyimages\.(com|co\.\w+)|media\.gettyimages/)

    # Try different patterns
    if match = url.match(/\/(\d{8,12})(?:\/|\?|$)/)
      match[1]
    elsif match = url.match(/detail\/[^\/]+\/[^\/]+-(\d{8,12})/)
      match[1]
    elsif match = url.match(/id\/(\d{8,12})/)
      match[1]
    else
      nil
    end
  end

  def self.getty_url?(url)
    url.match?(/gettyimages\.(com|co\.\w+)|media\.gettyimages/)
  end

  def get_image_metadata(image_id)
    uri = URI("#{API_BASE}/images/#{image_id}")
    uri.query = URI.encode_www_form(fields: "detail_set")

    request = Net::HTTP::Get.new(uri)
    request["Api-Key"] = @api_key
    request["Accept"] = "application/json"

    response = make_request(uri, request)
    parse_image_response(response, image_id)
  end

  def search_images(query, page: 1, per_page: 20)
    uri = URI("#{API_BASE}/search/images")
    uri.query = URI.encode_www_form(
      phrase: query,
      page: page,
      page_size: per_page,
      fields: "detail_set",
      sort_order: "best"
    )

    request = Net::HTTP::Get.new(uri)
    request["Api-Key"] = @api_key
    request["Accept"] = "application/json"

    response = make_request(uri, request)
    parse_search_response(response)
  end

  private

  def make_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 30

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      error_body = JSON.parse(response.body) rescue {}
      error_msg = error_body["message"] || "HTTP #{response.code}"
      Rails.logger.error "Getty API error: #{response.code} - #{response.body}"
      raise ApiError, "Getty API error: #{error_msg}"
    end

    JSON.parse(response.body)
  end

  def parse_image_response(data, image_id)
    images = data["images"] || [data]
    image = images.first

    return nil unless image

    {
      getty_id: image["id"] || image_id,
      title: image["title"],
      caption: image["caption"],
      date_taken: parse_date(image["date_created"]),
      date_submitted: parse_date(image["date_submitted"]),
      photographer: image.dig("artist"),
      collection: image.dig("collection_name"),
      location: extract_location(image),
      people: extract_people(image),
      keywords: image["keywords"]&.map { |k| k["text"] } || [],
      image_url: find_best_preview_url(image),
      getty_url: "https://www.gettyimages.com/detail/#{image["id"] || image_id}",
      editorial_use_only: image["editorial_segments"]&.any?,
      raw_data: image
    }
  end

  def parse_search_response(data)
    {
      total_results: data["result_count"],
      images: (data["images"] || []).map { |img| parse_image_response({ "images" => [img] }, img["id"]) }
    }
  end

  def parse_date(date_string)
    return nil unless date_string.present?
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  def extract_location(image)
    # Getty stores location info in various places
    city = image.dig("city")
    state = image.dig("state_province")
    country = image.dig("country")

    [city, state, country].compact.reject(&:blank?).join(", ")
  end

  def extract_people(image)
    # People are often in keywords or specific fields
    people = []

    # Check for personality keywords
    if image["keywords"]
      personality_keywords = image["keywords"].select { |k| k["type"] == "Personality" }
      people.concat(personality_keywords.map { |k| k["text"] })
    end

    # Check for people field if it exists
    if image["people"]
      people.concat(image["people"])
    end

    people.uniq
  end

  def find_best_preview_url(image)
    # Getty provides different size URIs
    display_sizes = image["display_sizes"] || []

    # Prefer larger previews for quality, but not too large
    preferred_order = ["high_res_comp", "comp", "preview", "thumb"]

    preferred_order.each do |size_name|
      size = display_sizes.find { |s| s["name"] == size_name }
      return size["uri"] if size && size["uri"]
    end

    # Fallback to first available
    display_sizes.first&.dig("uri")
  end
end
