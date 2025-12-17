class CreateImages < ActiveRecord::Migration[8.0]
  def change
    create_table :images do |t|
      t.string :title
      t.date :taken_date
      t.string :location
      t.text :notes

      t.timestamps
    end
  end
end
