class AddAccountToRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :entries, :account, foreign_key: true
    add_reference :characters, :account, foreign_key: true
    add_reference :sources, :account, foreign_key: true
    add_reference :articles, :account, foreign_key: true
    add_reference :images, :account, foreign_key: true
    add_reference :assets, :account, foreign_key: true
    add_reference :locations, :account, foreign_key: true
    add_reference :videos, :account, foreign_key: true
    add_reference :musics, :account, foreign_key: true
    add_reference :credits, :account, foreign_key: true
  end
end
