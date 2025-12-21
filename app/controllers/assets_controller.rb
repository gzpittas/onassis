class AssetsController < ApplicationController
  before_action :set_asset, only: %i[show edit update destroy]

  def index
    @assets = Asset.by_name.includes(:entries, :images)

    if params[:asset_type].present?
      @assets = @assets.by_type(params[:asset_type])
    end
  end

  def show
  end

  def new
    @asset = Asset.new
    @entries = Entry.chronological
    @images = Image.by_date
  end

  def create
    @asset = Asset.new(asset_params)

    if @asset.save
      redirect_to @asset, notice: "Asset was successfully created."
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
    if @asset.update(asset_params)
      redirect_to @asset, notice: "Asset was successfully updated."
    else
      @entries = Entry.chronological
      @images = Image.by_date
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    redirect_to assets_url, notice: "Asset was successfully deleted."
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:name, :asset_type, :description, :acquisition_date,
                                  :acquisition_date_precision, :disposition_date, :manufacturer, :notes,
                                  :reference_url, :reference_title, :featured_image_id,
                                  entry_ids: [], image_ids: [])
  end
end
