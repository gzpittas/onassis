class TimelineController < ApplicationController
  def index
    @entries = Entry.chronological.includes(:source, :characters, entry_sources: :source, images: { file_attachment: :blob }, featured_image: { file_attachment: :blob })

    if params[:year].present?
      @entries = @entries.by_year(params[:year])
    end

    decade_value = params[:decade].present? ? Entry.normalize_year_value(params[:decade]) : nil

    if params[:decade].present?
      @entries = @entries.by_decade(params[:decade])
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
      if decade_value && decade_value >= 0
        decade_start = Date.new(decade_value, 1, 1)
        decade_end = Date.new(decade_value + 10, 1, 1)
        @assets_with_dates = @assets_with_dates.where(acquisition_date: decade_start...decade_end)
        @images_with_dates = @images_with_dates.where(taken_date: decade_start...decade_end)
      else
        @assets_with_dates = @assets_with_dates.none
        @images_with_dates = @images_with_dates.none
      end
    end

    # Combine entries, assets, and images into unified timeline items
    @timeline_items = build_timeline_items(@entries, @assets_with_dates, @images_with_dates)

    @characters = Character.by_name
    entry_years = Entry.where.not(event_year: nil).pluck(:event_year)
    entry_decades = entry_years.map { |year| Entry.decade_value_from_year(year) }.uniq.sort
    @decades = entry_decades.map { |decade| [Entry.decade_label(decade), decade] }
    @entry_types = Entry::ENTRY_TYPES
  end

  private

  def build_timeline_items(entries, assets, images)
    items = []

    entries.each do |entry|
      sort_key = entry.sort_key
      next unless sort_key

      items << {
        type: :entry,
        sort_key: sort_key,
        year: entry.event_year_value,
        object: entry
      }
    end

    assets.each do |asset|
      sort_key = date_sort_key(asset.acquisition_date)
      next unless sort_key

      items << {
        type: :asset,
        sort_key: sort_key,
        year: asset.acquisition_date.year,
        object: asset
      }
    end

    images.each do |image|
      sort_key = date_sort_key(image.taken_date)
      next unless sort_key

      items << {
        type: :image,
        sort_key: sort_key,
        year: image.taken_date.year,
        object: image
      }
    end

    items.sort_by { |item| item[:sort_key] }
  end

  def date_sort_key(date)
    return nil unless date

    (date.year * 10000) + (date.month * 100) + date.day
  end
end
