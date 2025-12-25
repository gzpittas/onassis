class CreateCastingCandidates < ActiveRecord::Migration[8.0]
  def change
    create_table :casting_candidates do |t|
      t.references :character, null: false, foreign_key: true
      t.string :actor_name
      t.text :notes
      t.string :imdb_url
      t.string :image_url
      t.integer :priority

      t.timestamps
    end
  end
end
