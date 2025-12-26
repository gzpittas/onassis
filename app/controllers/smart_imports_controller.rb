class SmartImportsController < ApplicationController
  def new
    @images = Image.recent_first
    @characters = Character.by_name
    @locations = Location.order(:name)
    @assets = Asset.order(:name)
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

    # Check if this is an Alamy URL - scrape their page for metadata
    alamy_url = page_url.presence || url
    if AlamyScraperService.alamy_url?(alamy_url)
      return analyze_alamy(alamy_url, url)
    end

    if url.blank?
      render json: { error: "Please select an image" }, status: :unprocessable_entity
      return
    end

    characters = Character.pluck(:name)
    locations = Location.pluck(:name)
    assets = Asset.pluck(:name)

    analyzer = ImageAnalyzerService.new(url, characters: characters, locations: locations, assets: assets, page_url: page_url)
    result = analyzer.analyze

    # Map matched names to IDs
    matched_character_ids = Character.where(name: result[:matched_characters]).pluck(:id)
    matched_location_ids = Location.where(name: result[:matched_locations]).pluck(:id)
    matched_asset_ids = Asset.where(name: result[:matched_assets] || []).pluck(:id)

    render json: {
      success: true,
      analysis: result.merge(
        matched_character_ids: matched_character_ids,
        matched_location_ids: matched_location_ids,
        matched_asset_ids: matched_asset_ids
      )
    }
  rescue ImageAnalyzerService::AnalysisError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("Smart import error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
    render json: { error: "An unexpected error occurred. Please try again." }, status: :internal_server_error
  end

  def create
    @image = Image.new(image_params)

    Rails.logger.info "Smart Import: Creating image with params: #{image_params.inspect}"
    Rails.logger.info "Smart Import: Remote URL: #{params[:image][:remote_url]}"

    # Attach image from URL
    if params[:image][:remote_url].present?
      unless @image.attach_from_url(params[:image][:remote_url])
        Rails.logger.error "Smart Import: Failed to attach from URL. Errors: #{@image.errors.full_messages}"
        load_form_data
        flash.now[:alert] = "Failed to import image from URL: #{@image.errors[:remote_url].join(', ')}"
        render :new, status: :unprocessable_entity
        return
      end
      Rails.logger.info "Smart Import: Successfully attached image from URL"
    else
      Rails.logger.warn "Smart Import: No remote URL provided!"
    end

    if @image.save
      Rails.logger.info "Smart Import: Image saved successfully with ID: #{@image.id}"

      new_characters_created = []
      new_locations_created = []

      # Create new characters if approved
      if params[:new_characters].present?
        params[:new_characters].reject(&:blank?).each do |name|
          character = Character.create(name: name.strip)
          if character.persisted?
            @image.image_characters.create(character_id: character.id)
            new_characters_created << character.name
            Rails.logger.info "Smart Import: Created new character: #{character.name}"
          end
        end
      end

      # Create new locations if approved
      if params[:new_locations].present?
        params[:new_locations].reject(&:blank?).each do |name|
          location = Location.create(name: name.strip)
          if location.persisted?
            @image.image_locations.create(location_id: location.id)
            new_locations_created << location.name
            Rails.logger.info "Smart Import: Created new location: #{location.name}"
          end
        end
      end

      # Associate existing characters, locations, and assets
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

      if params[:image][:asset_ids].present?
        params[:image][:asset_ids].reject(&:blank?).each do |asset_id|
          @image.asset_images.create(asset_id: asset_id)
        end
      end

      # Build success message
      notice_parts = ["Image was successfully imported!"]
      notice_parts << "Created #{new_characters_created.count} new character(s): #{new_characters_created.join(', ')}" if new_characters_created.any?
      notice_parts << "Created #{new_locations_created.count} new location(s): #{new_locations_created.join(', ')}" if new_locations_created.any?

      redirect_to @image, notice: notice_parts.join(" ")
    else
      Rails.logger.error "Smart Import: Failed to save image. Errors: #{@image.errors.full_messages}"
      load_form_data
      flash.now[:alert] = @image.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
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

    # Combine all text to search
    text_to_search = [metadata[:caption], (metadata[:people] || []).join(" ")].compact.join(" ").downcase

    characters.each do |id, name|
      name_parts = name.downcase.split
      first_name = name_parts.first
      last_name = name_parts.last

      # Require BOTH first and last name to be present
      if name_parts.length >= 2
        if text_to_search.include?(first_name) && text_to_search.include?(last_name)
          matched_character_ids << id
        end
      else
        if text_to_search.include?(name.downcase)
          matched_character_ids << id
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

    # Match assets
    assets = Asset.pluck(:id, :name)
    matched_asset_ids = []

    asset_text = [metadata[:title], metadata[:caption]].compact.join(" ").downcase
    assets.each do |id, name|
      if asset_text.include?(name.downcase)
        matched_asset_ids << id
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
        matched_asset_ids: matched_asset_ids.uniq,
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

  def analyze_alamy(alamy_url, image_url = nil)
    scraper = AlamyScraperService.new(alamy_url)
    metadata = scraper.extract_metadata

    unless metadata
      render json: { error: "Could not extract metadata from Alamy page" }, status: :unprocessable_entity
      return
    end

    # Match people from Alamy to our characters
    characters = Character.pluck(:id, :name)
    matched_character_ids = []

    # Check headline/title for character names
    text_to_search = [metadata[:title], metadata[:description]].compact.join(" ").downcase

    characters.each do |id, name|
      name_parts = name.downcase.split
      first_name = name_parts.first
      last_name = name_parts.last

      # Require BOTH first and last name to be present (not just one)
      # This prevents matching "Christina Onassis" when only "Aristotle Onassis" is mentioned
      if name_parts.length >= 2
        # Both first and last name must appear in the text
        if text_to_search.include?(first_name) && text_to_search.include?(last_name)
          matched_character_ids << id
        end
      else
        # Single-word names: require exact match
        if text_to_search.include?(name.downcase)
          matched_character_ids << id
        end
      end
    end

    # Match locations
    locations = Location.pluck(:id, :name)
    matched_location_ids = []

    location_text = [metadata[:location], metadata[:title], metadata[:description]].compact.join(" ").downcase
    locations.each do |id, name|
      if location_text.include?(name.downcase)
        matched_location_ids << id
      end
    end

    # Match assets
    assets = Asset.pluck(:id, :name)
    matched_asset_ids = []

    asset_text = [metadata[:title], metadata[:description]].compact.join(" ").downcase
    assets.each do |id, name|
      if asset_text.include?(name.downcase)
        matched_asset_ids << id
      end
    end

    render json: {
      success: true,
      source: "alamy",
      analysis: {
        title: metadata[:title],
        description: metadata[:description],
        taken_date: metadata[:date_taken]&.strftime("%Y-%m-%d"),
        taken_date_precision: metadata[:date_precision],
        location: metadata[:location],
        matched_characters: [],
        matched_character_ids: matched_character_ids.uniq,
        matched_locations: [],
        matched_location_ids: matched_location_ids.uniq,
        matched_asset_ids: matched_asset_ids.uniq,
        suggested_new_characters: [],
        suggested_new_locations: [],
        confidence_notes: "Data scraped from Alamy. Photographer: #{metadata[:photographer]}. Agency: #{metadata[:agency]}.",
        alamy_id: metadata[:alamy_id],
        alamy_ref: metadata[:alamy_ref],
        alamy_url: metadata[:alamy_url],
        image_url: metadata[:image_url]
      }
    }
  rescue AlamyScraperService::ScraperError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def image_params
    params.require(:image).permit(
      :title, :taken_date, :taken_date_precision, :location, :notes,
      :source_url, :article_url, :article_title, :website_name, :website_url
    )
  end

  def load_form_data
    @images = Image.recent_first
    @characters = Character.by_name
    @locations = Location.order(:name)
    @assets = Asset.order(:name)
  end
end
