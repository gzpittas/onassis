require "net/http"
require "base64"

class ImageAnalyzerService
  class AnalysisError < StandardError; end

  def initialize(url, characters:, locations:, assets: [], page_url: nil)
    @url = url
    @characters = characters
    @locations = locations
    @assets = assets
    @page_url = page_url
  end

  def analyze
    image_data = fetch_image
    page_context = fetch_page_context

    prompt = build_prompt(page_context)
    response = call_openai(prompt, image_data)
    parse_response(response)
  rescue => e
    raise AnalysisError, "Failed to analyze image: #{e.message}"
  end

  private

  def fetch_image
    uri = URI.parse(@url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri.request_uri)
    # Use a real browser User-Agent to avoid blocks
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    request["Accept"] = "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8"
    request["Accept-Language"] = "en-US,en;q=0.9"
    request["Referer"] = @page_url if @page_url.present?

    response = http.request(request)

    # Handle redirects (up to 5)
    redirect_count = 0
    while response.is_a?(Net::HTTPRedirection) && redirect_count < 5
      redirect_url = response["location"]
      break unless redirect_url.present?

      # Handle relative redirects
      if redirect_url.start_with?("/")
        redirect_url = "#{uri.scheme}://#{uri.host}#{redirect_url}"
      end

      @url = redirect_url
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?

      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
      request["Accept"] = "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8"
      request["Referer"] = @page_url if @page_url.present?

      response = http.request(request)
      redirect_count += 1
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "Image fetch failed: #{response.code} for #{@url}"
      raise AnalysisError, "Failed to fetch image (#{response.code}). The server may be blocking direct access. Try a different image source."
    end

    content_type = response["Content-Type"]&.split(";")&.first

    # Some servers don't return proper content-type, try to detect from URL
    if content_type.nil? || !content_type.start_with?("image/")
      content_type = case @url.downcase
      when /\.jpe?g/ then "image/jpeg"
      when /\.png/ then "image/png"
      when /\.gif/ then "image/gif"
      when /\.webp/ then "image/webp"
      else
        raise AnalysisError, "URL does not appear to be an image"
      end
    end

    {
      data: Base64.strict_encode64(response.body),
      media_type: content_type
    }
  end

  def fetch_page_context
    context = "Image URL: #{@url}\n"

    if @page_url.present?
      begin
        uri = URI.parse(@page_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
        http.open_timeout = 10
        http.read_timeout = 30

        request = Net::HTTP::Get.new(uri.request_uri)
        request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          # Extract text content from HTML
          html = response.body.force_encoding("UTF-8")

          # Remove script and style tags
          html = html.gsub(/<script[^>]*>.*?<\/script>/mi, " ")
          html = html.gsub(/<style[^>]*>.*?<\/style>/mi, " ")

          # Extract title
          title_match = html.match(/<title[^>]*>(.*?)<\/title>/mi)
          page_title = title_match ? title_match[1].strip : ""

          # Extract meta description
          desc_match = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']+)["']/mi)
          desc_match ||= html.match(/<meta[^>]*content=["']([^"']+)["'][^>]*name=["']description["']/mi)
          meta_desc = desc_match ? desc_match[1].strip : ""

          # Extract image alt text and captions near the image
          alt_match = html.match(/alt=["']([^"']*(?:onassis|jackie|kennedy|callas|christina)[^"']*)["']/mi)
          img_alt = alt_match ? alt_match[1].strip : ""

          # Extract figcaption if present
          figcaption_match = html.match(/<figcaption[^>]*>(.*?)<\/figcaption>/mi)
          figcaption = figcaption_match ? figcaption_match[1].gsub(/<[^>]+>/, " ").strip : ""

          # Get article text (strip HTML tags, limit length)
          text_content = html.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
          text_content = text_content[0..3000] # Limit to avoid token limits

          context += "\nPage URL: #{@page_url}"
          context += "\nPage Title: #{page_title}" if page_title.present?
          context += "\nMeta Description: #{meta_desc}" if meta_desc.present?
          context += "\nImage Alt Text: #{img_alt}" if img_alt.present?
          context += "\nImage Caption: #{figcaption}" if figcaption.present?
          context += "\n\nPage Content:\n#{text_content}"
        end
      rescue => e
        Rails.logger.warn "Failed to fetch page content: #{e.message}"
      end
    end

    context
  end

  def build_prompt(page_context)
    <<~PROMPT
      You are analyzing a historical photograph related to Aristotle Onassis, the Greek shipping magnate.
      Please analyze this image and extract the following information.

      #{page_context}

      KNOWN PEOPLE IN OUR DATABASE:
      #{@characters.map { |c| "- #{c}" }.join("\n")}

      KNOWN LOCATIONS IN OUR DATABASE:
      #{@locations.map { |l| "- #{l}" }.join("\n")}

      KNOWN ASSETS IN OUR DATABASE (ships, properties, vehicles, etc.):
      #{@assets.map { |a| "- #{a}" }.join("\n")}

      Please provide your analysis in the following JSON format. Be as accurate as possible. If you're unsure about something, leave it blank or use your best estimate with a note in the description.

      {
        "title": "A concise, descriptive title for this image (e.g., 'Aristotle Onassis and Jackie Kennedy boarding Christina O')",
        "description": "A detailed description of what's happening in the image, who is visible, the setting, and any notable details. Include historical context if relevant.",
        "taken_date": "YYYY-MM-DD format if you can determine or estimate the date. Use your knowledge of when events occurred, fashion/style cues, etc.",
        "taken_date_precision": "One of: exact, month, year, decade, approximate. Use 'exact' only if you're very confident about the specific date.",
        "location": "The location where the photo was taken, if identifiable",
        "matched_characters": ["Array of names from the KNOWN PEOPLE list above that appear in this image - use exact names from the list"],
        "matched_locations": ["Array of names from the KNOWN LOCATIONS list above that relate to this image - use exact names from the list"],
        "matched_assets": ["Array of names from the KNOWN ASSETS list above that appear in this image - use exact names from the list"],
        "suggested_new_characters": ["People visible in the image who are NOT in our database - provide their full names if known"],
        "suggested_new_locations": ["Locations that should be added to our database"],
        "confidence_notes": "Any notes about your confidence level or uncertainties in this analysis"
      }

      Respond ONLY with the JSON object, no additional text.
    PROMPT
  end

  def call_openai(prompt, image_data)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image_url",
                image_url: {
                  url: "data:#{image_data[:media_type]};base64,#{image_data[:data]}"
                }
              },
              {
                type: "text",
                text: prompt
              }
            ]
          }
        ],
        max_tokens: 2048
      }
    )

    Rails.logger.info "OpenAI raw response keys: #{response.keys}" if response.is_a?(Hash)

    content = response.dig("choices", 0, "message", "content")

    if content.nil?
      error_msg = response.dig("error", "message") || "Unknown error"
      raise AnalysisError, "OpenAI API error: #{error_msg}"
    end

    content
  end

  def parse_response(response_text)
    raise AnalysisError, "Empty response from AI" if response_text.blank?

    Rails.logger.info "OpenAI response: #{response_text[0..500]}"

    # Extract JSON from the response (handle markdown code blocks)
    cleaned = response_text.gsub(/```json\s*/, "").gsub(/```\s*/, "")
    json_match = cleaned.match(/\{[\s\S]*\}/)
    raise AnalysisError, "No JSON found in response. Got: #{response_text[0..200]}" unless json_match

    JSON.parse(json_match[0]).with_indifferent_access
  rescue JSON::ParserError => e
    raise AnalysisError, "Failed to parse AI response: #{e.message}. Response: #{response_text[0..200]}"
  end
end
