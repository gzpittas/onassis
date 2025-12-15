class CreateEntryCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :entry_characters do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
