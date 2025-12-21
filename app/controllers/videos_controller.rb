class VideosController < ApplicationController
  before_action :set_video, only: %i[show edit update destroy]

  def index
    @videos = Video.by_title

    @videos = @videos.by_type(params[:video_type]) if params[:video_type].present?
  end

  def show
  end

  def new
    @video = Video.new
    load_associations
  end

  def create
    @video = Video.new(video_params)

    if @video.save
      redirect_to @video, notice: "Video was successfully added."
    else
      load_associations
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_associations
  end

  def update
    if @video.update(video_params)
      redirect_to @video, notice: "Video was successfully updated."
    else
      load_associations
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @video.destroy
    redirect_to videos_url, notice: "Video was successfully deleted."
  end

  private

  def set_video
    @video = Video.find(params[:id])
  end

  def load_associations
    @entries = Entry.chronological
    @characters = Character.by_name
    @assets = Asset.by_name
    @locations = Location.by_name
  end

  def video_params
    params.require(:video).permit(:title, :youtube_url, :vimeo_url, :other_url,
                                  :video_type, :duration, :publication_date,
                                  :source, :creator, :notes,
                                  entry_ids: [], character_ids: [], asset_ids: [], location_ids: [])
  end
end
