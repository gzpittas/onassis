class AddMainCharacterToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_reference :accounts, :main_character, foreign_key: { to_table: :characters }
  end
end
