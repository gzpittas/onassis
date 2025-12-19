class CreateEntryLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :entry_locations do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
