class CreateVideoLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :video_locations do |t|
      t.references :video, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
