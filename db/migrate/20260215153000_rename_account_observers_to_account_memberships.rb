class RenameAccountObserversToAccountMemberships < ActiveRecord::Migration[8.0]
  def change
    if table_exists?(:account_observers) && !table_exists?(:account_memberships)
      rename_table :account_observers, :account_memberships
    end

    return unless table_exists?(:account_memberships)

    # Some DBs may have been migrated before the unique index was introduced,
    # so don't assume any particular index names exist.
    if index_exists?(:account_memberships, [:account_id, :user_id], name: "index_account_observers_on_account_id_and_user_id")
      rename_index :account_memberships,
                   "index_account_observers_on_account_id_and_user_id",
                   "index_account_memberships_on_account_id_and_user_id"
    end

    if index_exists?(:account_memberships, :account_id, name: "index_account_observers_on_account_id")
      rename_index :account_memberships,
                   "index_account_observers_on_account_id",
                   "index_account_memberships_on_account_id"
    end

    if index_exists?(:account_memberships, :user_id, name: "index_account_observers_on_user_id")
      rename_index :account_memberships,
                   "index_account_observers_on_user_id",
                   "index_account_memberships_on_user_id"
    end

    unless column_exists?(:account_memberships, :role)
      add_column :account_memberships, :role, :string, null: false, default: "observer"
    end

    add_index :account_memberships, [:account_id, :user_id], unique: true, name: "index_account_memberships_on_account_id_and_user_id" unless index_exists?(:account_memberships, [:account_id, :user_id], unique: true)
    add_index :account_memberships, :account_id unless index_exists?(:account_memberships, :account_id)
    add_index :account_memberships, :user_id unless index_exists?(:account_memberships, :user_id)
  end
end
