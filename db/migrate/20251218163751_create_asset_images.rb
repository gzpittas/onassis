class CreateAssetImages < ActiveRecord::Migration[8.0]
  def change
    create_table :asset_images do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
