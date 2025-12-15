class AddAuthorToEntrySources < ActiveRecord::Migration[8.0]
  def change
    add_column :entry_sources, :author, :string
  end
end
