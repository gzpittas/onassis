class TimelineController < ApplicationController
  def index
    @entries = Entry.chronological.includes(:source, :characters, entry_sources: :source, images: { file_attachment: :blob }, featured_image: { file_attachment: :blob })

    if params[:year].present?
      @entries = @entries.by_year(params[:year])
    end

    if params[:decade].present?
      @entries = @entries.by_decade(params[:decade].to_i)
    end

    if params[:entry_type].present?
      @entries = @entries.by_type(params[:entry_type])
    end

    if params[:character_id].present?
      @entries = @entries.joins(:characters).where(characters: { id: params[:character_id] })
    end

    # Get assets with acquisition dates for timeline
    @assets_with_dates = Asset.where.not(acquisition_date: nil).includes(images: { file_attachment: :blob }, featured_image: { file_attachment: :blob }).order(:acquisition_date)

    # Get images with taken dates for timeline
    @images_with_dates = Image.where.not(taken_date: nil).includes(:characters, file_attachment: :blob).order(:taken_date)

    # Get undated images (only when not filtering by decade)
    @undated_images = params[:decade].blank? ? Image.where(taken_date: nil).includes(:characters, file_attachment: :blob).recent_first : []

    if params[:decade].present?
      decade_start = Date.new(params[:decade].to_i, 1, 1)
      decade_end = Date.new(params[:decade].to_i + 10, 1, 1)
      @assets_with_dates = @assets_with_dates.where(acquisition_date: decade_start...decade_end)
      @images_with_dates = @images_with_dates.where(taken_date: decade_start...decade_end)
    end

    # Combine entries, assets, and images into unified timeline items
    @timeline_items = build_timeline_items(@entries, @assets_with_dates, @images_with_dates)

    @characters = Character.by_name
    @decades = (1900..1970).step(10).to_a
    @entry_types = Entry::ENTRY_TYPES
  end

  private

  def build_timeline_items(entries, assets, images)
    items = []

    entries.each do |entry|
      items << {
        type: :entry,
        date: entry.event_date,
        object: entry
      }
    end

    assets.each do |asset|
      items << {
        type: :asset,
        date: asset.acquisition_date,
        object: asset
      }
    end

    images.each do |image|
      items << {
        type: :image,
        date: image.taken_date,
        object: image
      }
    end

    items.sort_by { |item| item[:date] }
  end
end
