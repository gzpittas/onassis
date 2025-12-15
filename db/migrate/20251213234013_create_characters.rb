class CreateCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :characters do |t|
      t.string :name
      t.date :birth_date
      t.date :death_date
      t.string :relationship
      t.string :nationality
      t.string :occupation
      t.text :bio

      t.timestamps
    end
  end
end
