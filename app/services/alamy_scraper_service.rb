require "net/http"
require "json"

class AlamyScraperService
  class ScraperError < StandardError; end

  def self.alamy_url?(url)
    url.match?(/alamy\.(com|de|fr|it|es)/)
  end

  def self.extract_image_id(url)
    # Extract ID from URLs like:
    # https://www.alamy.com/stock-photo-...-106980379.html
    # https://www.alamy.com/...-image123456789.html
    if match = url.match(/-(\d{6,12})\.html/)
      match[1]
    else
      nil
    end
  end

  def initialize(url)
    @url = url
  end

  def extract_metadata
    html = fetch_page
    data = extract_next_data(html)

    return nil unless data

    product = data.dig("props", "pageProps", "product")
    return nil unless product

    parse_product(product)
  end

  private

  def fetch_page
    uri = URI.parse(@url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    request["Accept"] = "text/html,application/xhtml+xml"
    request["Accept-Language"] = "en-US,en;q=0.9"

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise ScraperError, "Failed to fetch Alamy page: #{response.code}"
    end

    response.body.force_encoding("UTF-8")
  end

  def extract_next_data(html)
    # Find __NEXT_DATA__ script
    match = html.match(/__NEXT_DATA__[^>]*>([^<]+)</)
    return nil unless match

    JSON.parse(match[1])
  rescue JSON::ParserError
    nil
  end

  def parse_product(product)
    # Extract date from firstcreated (format: YYYYMMDD)
    date_taken = nil
    if product["firstcreated"].present?
      date_str = product["firstcreated"].to_s
      if date_str.length == 8
        year = date_str[0..3]
        month = date_str[4..5]
        day = date_str[6..7]
        date_taken = Date.new(year.to_i, month.to_i, day.to_i) rescue nil
      end
    end

    # Extract image URL from renditions or construct it
    image_url = nil
    if product["renditions"].is_a?(Hash)
      # Prefer comp or preview size for display
      rendition = product["renditions"]["comp"] ||
                  product["renditions"]["preview"] ||
                  product["renditions"]["zoom"] ||
                  product["renditions"].values.first
      image_url = rendition["href"] if rendition.is_a?(Hash)
    end

    # Fallback: construct URL from altids
    if image_url.blank? && product.dig("altids", "ref")
      ref = product.dig("altids", "ref")
      image_url = "https://c7.alamy.com/comp/#{ref}/#{ref.downcase}.jpg"
    end

    # Extract keywords/people
    keywords = []
    people = []
    if product["subject"]
      product["subject"].each do |subj|
        name = subj["name"]
        next unless name.present?

        # Try to identify people vs keywords
        if name.match?(/onassis|kennedy|callas|churchill|niarchos|livanos/i)
          people << name
        else
          keywords << name
        end
      end
    end

    # Extract location from title, description, or keywords
    location = nil
    # Check title first for location mentions
    title_text = product["headline"] || ""
    if match = title_text.match(/(in|at)\s+([A-Z][a-zA-Z\s]+?)\.?$/i)
      location = match[2].strip
    end

    # If not found in title, check keywords
    if location.blank?
      location_patterns = /monte carlo|paris|london|athens|greece|new york|skorpios|cannes|monaco|capri|sardinia|st\.?\s*moritz/i
      location_keywords = keywords.select { |k| k.match?(location_patterns) }
      location = location_keywords.first&.titleize if location_keywords.any?
    end

    # Get photographer/agency
    photographer = product["byline"]
    agency = product.dig("meta", "agency", "name")

    {
      title: product["headline"] || product["headline_en"],
      description: product["description_text"],
      date_taken: date_taken,
      date_precision: date_taken ? "exact" : nil,
      location: location,
      photographer: photographer,
      agency: agency,
      people: people,
      keywords: keywords,
      image_url: image_url,
      alamy_id: product.dig("altids", "id"),
      alamy_ref: product.dig("altids", "ref"),
      alamy_url: @url,
      is_archive: product.dig("meta", "isarchive"),
      is_black_and_white: product.dig("meta", "blackandwhite")
    }
  end
end
