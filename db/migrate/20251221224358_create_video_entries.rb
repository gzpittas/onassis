class CreateVideoEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :video_entries do |t|
      t.references :video, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true

      t.timestamps
    end
  end
end
