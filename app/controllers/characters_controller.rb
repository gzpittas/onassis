class CharactersController < ApplicationController
  before_action :set_character, only: %i[show edit update destroy]

  def index
    @characters = Character.by_name.includes(images: { file_attachment: :blob }, featured_image: { file_attachment: :blob })

    if params[:relationship].present?
      @characters = @characters.where(relationship: params[:relationship])
    end
  end

  def show
    @entries = @character.entries.chronological.includes(:source)
  end

  def new
    @character = Character.new
    @images = Image.recent_first
  end

  def create
    @character = Character.new(character_params)

    if @character.save
      redirect_to @character, notice: "Character was successfully created."
    else
      @images = Image.recent_first
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @images = Image.recent_first
  end

  def update
    if @character.update(character_params)
      redirect_to @character, notice: "Character was successfully updated."
    else
      @images = Image.recent_first
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @character.destroy
    redirect_to characters_url, notice: "Character was successfully deleted."
  end

  private

  def set_character
    @character = Character.find(params[:id])
  end

  def character_params
    params.require(:character).permit(:name, :birth_date, :death_date, :relationship,
                                      :nationality, :occupation, :bio, :lead_character,
                                      :featured_image_id, image_ids: [],
                                      character_links_attributes: [:id, :url, :label, :_destroy])
  end
end
