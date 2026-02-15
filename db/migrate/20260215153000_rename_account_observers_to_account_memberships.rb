class RenameAccountObserversToAccountMemberships < ActiveRecord::Migration[8.0]
  def change
    rename_table :account_observers, :account_memberships

    rename_index :account_memberships,
                 "index_account_observers_on_account_id_and_user_id",
                 "index_account_memberships_on_account_id_and_user_id"
    rename_index :account_memberships,
                 "index_account_observers_on_account_id",
                 "index_account_memberships_on_account_id"
    rename_index :account_memberships,
                 "index_account_observers_on_user_id",
                 "index_account_memberships_on_user_id"

    add_column :account_memberships, :role, :string, null: false, default: "observer"
  end
end

