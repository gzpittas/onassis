class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :location_type
      t.string :continent
      t.string :country
      t.string :region
      t.string :city
      t.string :neighborhood
      t.string :address
      t.string :building
      t.string :room
      t.text :description
      t.text :notes

      t.timestamps
    end
  end
end
