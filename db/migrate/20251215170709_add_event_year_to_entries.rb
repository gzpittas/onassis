class AddEventYearToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :event_year, :integer
    add_column :entries, :event_month, :integer
    add_column :entries, :event_day, :integer
    add_column :entries, :end_year, :integer
    add_column :entries, :end_month, :integer
    add_column :entries, :end_day, :integer
  end
end
