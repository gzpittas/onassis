class CreateEntryImages < ActiveRecord::Migration[8.0]
  def change
    create_table :entry_images do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
