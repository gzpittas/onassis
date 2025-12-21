class CreateVideoCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :video_characters do |t|
      t.references :video, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true

      t.timestamps
    end
  end
end
