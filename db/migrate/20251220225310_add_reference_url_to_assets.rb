class AddReferenceUrlToAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :assets, :reference_url, :string
    add_column :assets, :reference_title, :string
  end
end
