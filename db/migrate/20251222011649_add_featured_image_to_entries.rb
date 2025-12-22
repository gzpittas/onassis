class AddFeaturedImageToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :featured_image_id, :integer
  end
end
