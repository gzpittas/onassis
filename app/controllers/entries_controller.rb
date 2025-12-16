class EntriesController < ApplicationController
  before_action :set_entry, only: %i[show edit update destroy add_source remove_source]

  def index
    @entries = Entry.chronological.includes(:source, :sources, :characters)

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

    if params[:source_id].present?
      @entries = @entries.joins(:entry_sources).where(entry_sources: { source_id: params[:source_id] })
    end

    if params[:verified].present?
      @entries = params[:verified] == "true" ? @entries.verified : @entries.unverified
    end
  end

  def show
  end

  def new
    @entry = Entry.new
    @entry.character_ids = Character.lead.pluck(:id)
    @entry.entry_sources.build
    @sources = Source.order(:title)
    @characters = Character.by_name
  end

  def create
    @entry = Entry.new(entry_params)
    add_lead_characters

    if @entry.save
      redirect_to @entry, notice: "Entry was successfully created."
    else
      @sources = Source.order(:title)
      @characters = Character.by_name
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @entry.entry_sources.build if @entry.entry_sources.empty? || params[:add_source]
    @sources = Source.order(:title)
    @characters = Character.by_name
  end

  def update
    if @entry.update(entry_params)
      redirect_to @entry, notice: "Entry was successfully updated."
    else
      @sources = Source.order(:title)
      @characters = Character.by_name
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to entries_url, notice: "Entry was successfully deleted."
  end

  def add_source
    @sources = Source.order(:title)
    @entry_source = @entry.entry_sources.build
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_entry_path(@entry) }
    end
  end

  def remove_source
    entry_source = @entry.entry_sources.find(params[:entry_source_id])
    entry_source.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("entry_source_#{params[:entry_source_id]}") }
      format.html { redirect_to edit_entry_path(@entry), notice: "Source removed." }
    end
  end

  private

  def set_entry
    @entry = Entry.find(params[:id])
  end

  def entry_params
    params.require(:entry).permit(:title, :event_date, :end_date, :location, :entry_type,
                                  :description, :significance, :verified,
                                  character_ids: [],
                                  entry_sources_attributes: [:id, :source_id, :page_reference, :author, :notes, :link, :_destroy])
  end

  def add_lead_characters
    lead_ids = Character.lead.pluck(:id)
    @entry.character_ids = (@entry.character_ids + lead_ids).uniq
  end
end
