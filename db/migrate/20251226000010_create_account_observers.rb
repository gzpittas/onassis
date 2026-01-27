class CreateAccountObservers < ActiveRecord::Migration[8.0]
  def change
    create_table :account_observers do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :account_observers, [:account_id, :user_id], unique: true
  end
end
