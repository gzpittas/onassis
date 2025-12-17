class ImagesController < ApplicationController
  before_action :set_image, only: %i[show edit update destroy]

  def index
    @images = Image.by_date.includes(:entries, :characters)

    if params[:decade].present?
      decade_start = Date.new(params[:decade].to_i, 1, 1)
      decade_end = Date.new(params[:decade].to_i + 10, 1, 1)
      @images = @images.where(taken_date: decade_start...decade_end)
    end

    if params[:character_id].present?
      @images = @images.joins(:image_characters).where(image_characters: { character_id: params[:character_id] })
    end
  end

  def show
  end

  def new
    @image = Image.new
    @entries = Entry.chronological
    @characters = Character.by_name
  end

  def create
    @image = Image.new(image_params)

    if @image.save
      redirect_to @image, notice: "Image was successfully uploaded."
    else
      @entries = Entry.chronological
      @characters = Character.by_name
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @entries = Entry.chronological
    @characters = Character.by_name
  end

  def update
    if @image.update(image_params)
      redirect_to @image, notice: "Image was successfully updated."
    else
      @entries = Entry.chronological
      @characters = Character.by_name
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image.file.purge
    @image.destroy
    redirect_to images_url, notice: "Image was successfully deleted."
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :file, :taken_date, :location, :notes,
                                  entry_ids: [], character_ids: [])
  end
end
