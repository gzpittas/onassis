class CreateEntryArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :entry_articles do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
