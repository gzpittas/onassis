class AddSourceFieldsToImages < ActiveRecord::Migration[8.0]
  def change
    add_column :images, :article_url, :string
    add_column :images, :article_title, :string
    add_column :images, :article_author, :string
    add_column :images, :website_name, :string
    add_column :images, :website_url, :string
  end
end
