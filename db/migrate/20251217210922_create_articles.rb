class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :publication
      t.string :author
      t.date :publication_date
      t.string :url
      t.text :notes

      t.timestamps
    end
  end
end
