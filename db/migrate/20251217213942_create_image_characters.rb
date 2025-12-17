class CreateImageCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :image_characters do |t|
      t.references :image, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true

      t.timestamps
    end
  end
end
