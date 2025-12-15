class SourcesController < ApplicationController
  before_action :set_source, only: %i[show edit update destroy]

  def index
    @sources = Source.order(:title)

    if params[:source_type].present?
      @sources = @sources.where(source_type: params[:source_type])
    end
  end

  def show
    @entries = @source.entries.chronological.includes(:characters)
  end

  def new
    @source = Source.new
  end

  def create
    @source = Source.new(source_params)

    if @source.save
      redirect_to @source, notice: "Source was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @source.update(source_params)
      redirect_to @source, notice: "Source was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @source.destroy
    redirect_to sources_url, notice: "Source was successfully deleted."
  end

  private

  def set_source
    @source = Source.find(params[:id])
  end

  def source_params
    params.require(:source).permit(:title, :author, :source_type, :publication_date,
                                   :publisher, :notes,
                                   source_links_attributes: [:id, :url, :label, :_destroy])
  end
end
