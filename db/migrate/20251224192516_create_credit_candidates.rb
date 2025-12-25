class CreateCreditCandidates < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_candidates do |t|
      t.references :credit, null: false, foreign_key: true
      t.string :person_name
      t.text :notes
      t.string :imdb_url
      t.string :image_url
      t.integer :priority

      t.timestamps
    end
  end
end
