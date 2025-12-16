class AddLeadCharacterToCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :lead_character, :boolean, default: false
  end
end
