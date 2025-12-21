class AddFeaturedImageToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :featured_image_id, :integer
  end
end
