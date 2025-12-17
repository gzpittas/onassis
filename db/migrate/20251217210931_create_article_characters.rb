class CreateArticleCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :article_characters do |t|
      t.references :article, null: false, foreign_key: true
      t.references :character, null: false, foreign_key: true

      t.timestamps
    end
  end
end
