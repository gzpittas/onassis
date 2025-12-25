class CreateCredits < ActiveRecord::Migration[8.0]
  def change
    create_table :credits do |t|
      t.string :title
      t.text :description
      t.integer :priority

      t.timestamps
    end
  end
end
