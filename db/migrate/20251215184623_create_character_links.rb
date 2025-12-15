class CreateCharacterLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :character_links do |t|
      t.references :character, null: false, foreign_key: true
      t.string :url
      t.string :label

      t.timestamps
    end
  end
end
