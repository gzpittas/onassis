class LocationsController < ApplicationController
  before_action :set_location, only: %i[show edit update destroy]

  def index
    @locations = Location.by_name.includes(:entries, :images)

    if params[:location_type].present?
      @locations = @locations.by_type(params[:location_type])
    end

    if params[:country].present?
      @locations = @locations.by_country(params[:country])
    end
  end

  def show
  end

  def new
    @location = Location.new
    @entries = Entry.chronological
    @images = Image.by_date
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to @location, notice: "Location was successfully created."
    else
      @entries = Entry.chronological
      @images = Image.by_date
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @entries = Entry.chronological
    @images = Image.by_date
  end

  def update
    if @location.update(location_params)
      redirect_to @location, notice: "Location was successfully updated."
    else
      @entries = Entry.chronological
      @images = Image.by_date
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to locations_url, notice: "Location was successfully deleted."
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :location_type, :continent, :country, :region,
                                     :city, :neighborhood, :address, :building, :room,
                                     :description, :notes,
                                     entry_ids: [], image_ids: [])
  end
end
