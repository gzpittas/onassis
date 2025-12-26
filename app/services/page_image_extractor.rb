require "net/http"

class PageImageExtractor
  MIN_WIDTH = 200
  MIN_HEIGHT = 200

  def initialize(page_url)
    @page_url = page_url
    @base_uri = URI.parse(page_url)
  end

  def extract
    html = fetch_page
    extract_images(html)
  end

  private

  def fetch_page
    uri = URI.parse(@page_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    response = http.request(request)

    # Handle redirects
    if response.is_a?(Net::HTTPRedirection)
      @page_url = response["location"]
      @base_uri = URI.parse(@page_url)
      return fetch_page
    end

    raise "Failed to fetch page: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body.force_encoding("UTF-8")
  end

  def extract_images(html)
    images = []

    # Find all img tags
    html.scan(/<img[^>]+>/i).each do |img_tag|
      src = extract_src(img_tag)
      next unless src

      # Skip tiny images, icons, tracking pixels
      next if skip_image?(img_tag, src)

      full_url = resolve_url(src)
      next unless full_url

      alt = img_tag.match(/alt=["']([^"']*)["']/i)&.[](1) || ""
      title = img_tag.match(/title=["']([^"']*)["']/i)&.[](1) || ""

      images << {
        url: full_url,
        alt: alt,
        title: title,
        caption: alt.presence || title.presence || ""
      }
    end

    # Also look for og:image meta tags (often high quality)
    og_image = html.match(/<meta[^>]*property=["']og:image["'][^>]*content=["']([^"']+)["']/i)
    og_image ||= html.match(/<meta[^>]*content=["']([^"']+)["'][^>]*property=["']og:image["']/i)

    if og_image
      url = resolve_url(og_image[1])
      if url && !images.any? { |i| i[:url] == url }
        images.unshift({
          url: url,
          alt: "Featured image",
          title: "",
          caption: "Featured image"
        })
      end
    end

    # Deduplicate and limit
    images.uniq { |i| i[:url] }.first(20)
  end

  def extract_src(img_tag)
    # Try data-src first (lazy loaded images)
    src = img_tag.match(/data-src=["']([^"']+)["']/i)&.[](1)
    src ||= img_tag.match(/data-lazy-src=["']([^"']+)["']/i)&.[](1)
    src ||= img_tag.match(/srcset=["']([^\s"']+)/i)&.[](1)
    src ||= img_tag.match(/src=["']([^"']+)["']/i)&.[](1)
    src
  end

  def skip_image?(img_tag, src)
    # Skip based on filename patterns
    return true if src.match?(/logo|icon|avatar|button|arrow|sprite|tracking|pixel|blank|spacer|1x1/i)
    return true if src.match?(/\.(gif|svg)$/i) && !src.match?(/photo|image/i)
    return true if src.match?(/base64/i) && src.length < 1000

    # Skip based on size attributes
    width = img_tag.match(/width=["']?(\d+)/i)&.[](1)&.to_i || 999
    height = img_tag.match(/height=["']?(\d+)/i)&.[](1)&.to_i || 999

    return true if width < MIN_WIDTH || height < MIN_HEIGHT

    # Skip based on class names
    return true if img_tag.match?(/class=["'][^"']*(icon|logo|avatar|thumb-small)[^"']*["']/i)

    false
  end

  def resolve_url(src)
    return nil if src.blank?
    return src if src.start_with?("http://", "https://")

    begin
      if src.start_with?("//")
        "#{@base_uri.scheme}:#{src}"
      elsif src.start_with?("/")
        "#{@base_uri.scheme}://#{@base_uri.host}#{src}"
      else
        "#{@base_uri.scheme}://#{@base_uri.host}/#{src}"
      end
    rescue
      nil
    end
  end
end
