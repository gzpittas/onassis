class MusicsController < ApplicationController
  before_action :set_music, only: %i[show edit update destroy]

  def index
    @musics = Music.by_title

    @musics = @musics.by_genre(params[:genre]) if params[:genre].present?
    @musics = @musics.by_mood(params[:mood]) if params[:mood].present?
    @musics = @musics.by_era(params[:era]) if params[:era].present?
  end

  def show
  end

  def new
    @music = Music.new
  end

  def create
    @music = Music.new(music_params)

    if @music.save
      redirect_to @music, notice: "Music was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @music.update(music_params)
      redirect_to @music, notice: "Music was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @music.destroy
    redirect_to musics_url, notice: "Music was successfully deleted."
  end

  private

  def set_music
    @music = Music.find(params[:id])
  end

  def music_params
    params.require(:music).permit(:title, :artist, :composer, :spotify_url, :youtube_url,
                                  :apple_music_url, :genre, :era, :mood, :usage_type, :notes)
  end
end
