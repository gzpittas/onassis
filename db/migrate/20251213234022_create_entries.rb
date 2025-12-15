class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.string :title
      t.date :event_date
      t.date :end_date
      t.string :location
      t.string :entry_type
      t.text :description
      t.text :significance
      t.references :source, null: false, foreign_key: true
      t.string :page_reference
      t.boolean :verified

      t.timestamps
    end
  end
end
