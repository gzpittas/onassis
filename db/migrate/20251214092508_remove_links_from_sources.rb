class RemoveLinksFromSources < ActiveRecord::Migration[8.0]
  def change
    remove_column :sources, :links, :text
  end
end
