class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.string :name
      t.string :asset_type
      t.text :description
      t.date :acquisition_date
      t.string :disposition_date
      t.string :manufacturer
      t.text :notes

      t.timestamps
    end
  end
end
