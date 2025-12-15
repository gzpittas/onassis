class RemoveSourceIdNotNullFromEntries < ActiveRecord::Migration[8.0]
  def change
    change_column_null :entries, :source_id, true
  end
end
