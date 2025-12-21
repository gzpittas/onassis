class AddFeaturedImageToAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :assets, :featured_image_id, :integer
  end
end
