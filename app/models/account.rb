class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"

  has_many :account_observers, dependent: :destroy
  has_many :observers, through: :account_observers, source: :user

  has_many :entries, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :sources, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :assets, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :musics, dependent: :destroy
  has_many :credits, dependent: :destroy

  validates :name, presence: true

  def adopt_unscoped_records!
    [
      Entry,
      Character,
      Source,
      Article,
      Image,
      Asset,
      Location,
      Video,
      Music,
      Credit
    ].each do |model|
      model.unscoped.where(account_id: nil).update_all(account_id: id)
    end
  end
end
