class AddLinkToEntrySources < ActiveRecord::Migration[8.0]
  def change
    add_column :entry_sources, :link, :string
  end
end
