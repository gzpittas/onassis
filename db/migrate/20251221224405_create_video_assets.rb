class CreateVideoAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :video_assets do |t|
      t.references :video, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true

      t.timestamps
    end
  end
end
