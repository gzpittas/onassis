class SmartImportsController < ApplicationController
  def new
    @images = Image.recent_first
    @characters = Character.by_name
    @locations = Location.order(:name)
  end

  def analyze
    url = params[:url]

    if url.blank?
      render json: { error: "Please provide an image URL" }, status: :unprocessable_entity
      return
    end

    characters = Character.pluck(:name)
    locations = Location.pluck(:name)

    analyzer = ImageAnalyzerService.new(url, characters: characters, locations: locations)
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
