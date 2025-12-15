class AddLinksToSources < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :links, :text
  end
end
