class TimelineController < ApplicationController
  def index
    @entries = Entry.chronological.includes(:source, :characters, entry_sources: :source)

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

    @characters = Character.by_name
    @decades = (1900..1970).step(10).to_a
    @entry_types = Entry::ENTRY_TYPES
  end
end
