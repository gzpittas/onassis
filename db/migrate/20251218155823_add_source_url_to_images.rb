class AddSourceUrlToImages < ActiveRecord::Migration[8.0]
  def change
    add_column :images, :source_url, :string
  end
end
