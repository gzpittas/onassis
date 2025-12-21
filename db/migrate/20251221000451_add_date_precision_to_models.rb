class AddDatePrecisionToModels < ActiveRecord::Migration[8.0]
  def change
    # Entry: event_date precision
    add_column :entries, :date_precision, :string, default: 'exact'

    # Asset: acquisition_date precision
    add_column :assets, :acquisition_date_precision, :string, default: 'exact'

    # Image: taken_date precision
    add_column :images, :taken_date_precision, :string, default: 'exact'
  end
end
