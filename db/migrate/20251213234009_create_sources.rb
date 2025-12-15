class CreateSources < ActiveRecord::Migration[8.0]
  def change
    create_table :sources do |t|
      t.string :title
      t.string :author
      t.string :source_type
      t.date :publication_date
      t.string :publisher
      t.text :notes

      t.timestamps
    end
  end
end
