class SmartImportsController < ApplicationController
  def new
    @images = Image.recent_first
    @characters = Character.by_name
    @locations = Location.order(:name)
  end

  def fetch_images
    page_url = params[:page_url]

    if page_url.blank?
      render json: { error: "Please provide a page URL" }, status: :unprocessable_entity
      return
    end

    images = PageImageExtractor.new(page_url).extract
    render json: { success: true, images: images }
  rescue => e
    Rails.logger.error("Fetch images error: #{e.message}")
    render json: { error: "Failed to fetch images from page: #{e.message}" }, status: :unprocessable_entity
  end

  def analyze
    url = params[:url]
    page_url = params[:page_url]

    if url.blank? && page_url.blank?
      render json: { error: "Please provide an image URL or page URL" }, status: :unprocessable_entity
      return
    end

    # Check if this is a Getty URL - use their API for better metadata
    getty_url = page_url.presence || url
    if GettyApiService.getty_url?(getty_url)
      return analyze_getty(getty_url, url)
    end

    if url.blank?
      render json: { error: "Please select an image" }, status: :unprocessable_entity
      return
    end

    characters = Character.pluck(:name)
    locations = Location.pluck(:name)

    analyzer = ImageAnalyzerService.new(url, characters: characters, locations: locations, page_url: page_url)
    result = analyzer.analyze

    # Map matched names to IDs
    matched_character_ids = Character.where(name: result[:matched_characters]).pluck(:id)
    matched_location_ids = Location.where(name: result[:matched_locations]).pluck(:id)

    render json: {
      success: true,
      analysis: result.merge(
        matched_character_ids: matched_character_ids,
        matched_location_ids: matched_location_ids
      )
    }
  rescue ImageAnalyzerService::AnalysisError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("Smart import error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    render json: { error: "An unexpected error occurred. Please try again." }, status: :internal_server_error
  end

  private

  def analyze_getty(getty_url, image_url = nil)
    image_id = GettyApiService.extract_image_id(getty_url)

    unless image_id
      render json: { error: "Could not extract Getty image ID from URL" }, status: :unprocessable_entity
      return
    end

    getty = GettyApiService.new
    metadata = getty.get_image_metadata(image_id)

    unless metadata
      render json: { error: "Could not fetch metadata from Getty" }, status: :unprocessable_entity
      return
    end

    # Match people from Getty to our characters
    characters = Character.pluck(:id, :name)
    matched_character_ids = []

    if metadata[:people].present?
      metadata[:people].each do |person|
        # Try to find matching character (case-insensitive partial match)
        match = characters.find { |id, name| name.downcase.include?(person.downcase) || person.downcase.include?(name.downcase.split.first) }
        matched_character_ids << match[0] if match
      end
    end

    # Also check caption for character names
    if metadata[:caption].present?
      characters.each do |id, name|
        if metadata[:caption].downcase.include?(name.downcase.split.first)
          matched_character_ids << id unless matched_character_ids.include?(id)
        end
      end
    end

    # Match locations
    locations = Location.pluck(:id, :name)
    matched_location_ids = []

    location_text = [metadata[:location], metadata[:caption]].compact.join(" ").downcase
    locations.each do |id, name|
      if location_text.include?(name.downcase)
        matched_location_ids << id
      end
    end

    render json: {
      success: true,
      source: "getty",
      analysis: {
        title: metadata[:title],
        description: metadata[:caption],
        taken_date: metadata[:date_taken]&.strftime("%Y-%m-%d"),
        taken_date_precision: metadata[:date_taken] ? "exact" : nil,
        location: metadata[:location],
        matched_characters: metadata[:people] || [],
        matched_character_ids: matched_character_ids.uniq,
        matched_locations: [],
        matched_location_ids: matched_location_ids.uniq,
        suggested_new_characters: (metadata[:people] || []) - Character.pluck(:name),
        suggested_new_locations: [],
        confidence_notes: "Data from Getty Images API. Photographer: #{metadata[:photographer]}. Collection: #{metadata[:collection]}.",
        getty_id: metadata[:getty_id],
        getty_url: metadata[:getty_url],
        image_url: metadata[:image_url]
      }
    }
  rescue GettyApiService::ApiError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def create
    @image = Image.new(image_params)

    # Attach image from URL
    if params[:image][:remote_url].present?
      unless @image.attach_from_url(params[:image][:remote_url])
        @images = Image.recent_first
        @characters = Character.by_name
        @locations = Location.order(:name)
        flash.now[:alert] = "Failed to import image from URL"
        render :new, status: :unprocessable_entity
        return
      end
    end

    if @image.save
      # Associate characters and locations
      if params[:image][:character_ids].present?
        params[:image][:character_ids].reject(&:blank?).each do |char_id|
          @image.image_characters.create(character_id: char_id)
        end
      end

      if params[:image][:location_ids].present?
        params[:image][:location_ids].reject(&:blank?).each do |loc_id|
          @image.image_locations.create(location_id: loc_id)
        end
      end

      redirect_to @image, notice: "Image was successfully imported!"
    else
      @images = Image.recent_first
      @characters = Character.by_name
      @locations = Location.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def image_params
    params.require(:image).permit(
      :title, :taken_date, :taken_date_precision, :location, :notes,
      :source_url, :article_url, :article_title, :website_name, :website_url
    )
  end
end
