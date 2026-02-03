class AddMaxTimelinesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :max_timelines, :integer, default: 1, null: false
  end
end
