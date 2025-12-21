class AddFeaturedImageToCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :featured_image_id, :integer
  end
end
