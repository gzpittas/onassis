class CastingCandidatesController < ApplicationController
  before_action :require_write_access, except: :show
  before_action :set_character
  before_action :set_casting_candidate, only: %i[show edit update destroy]

  def show
  end

  def new
    @casting_candidate = @character.casting_candidates.build
  end

  def create
    @casting_candidate = @character.casting_candidates.build(casting_candidate_params)

    if @casting_candidate.save
      redirect_to @character, notice: "Casting candidate was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @casting_candidate.update(casting_candidate_params)
      redirect_to @character, notice: "Casting candidate was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @casting_candidate.destroy
    redirect_to @character, notice: "Casting candidate was successfully removed."
  end

  private

  def set_character
    @character = Character.find(params[:character_id])
  end

  def set_casting_candidate
    @casting_candidate = @character.casting_candidates.find(params[:id])
  end

  def casting_candidate_params
    params.require(:casting_candidate).permit(:actor_name, :notes, :imdb_url, :image_url, :priority)
  end
end
