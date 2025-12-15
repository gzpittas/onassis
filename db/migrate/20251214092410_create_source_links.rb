class CreateSourceLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :source_links do |t|
      t.references :source, null: false, foreign_key: true
      t.string :url
      t.string :label

      t.timestamps
    end
  end
end
