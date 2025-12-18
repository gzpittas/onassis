class CreateEntryAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :entry_assets do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.string :notes

      t.timestamps
    end
  end
end
