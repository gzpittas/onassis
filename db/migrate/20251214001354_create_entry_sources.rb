class CreateEntrySources < ActiveRecord::Migration[8.0]
  def change
    create_table :entry_sources do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :source, null: false, foreign_key: true
      t.string :page_reference
      t.text :notes

      t.timestamps
    end
  end
end
