class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :main_character, -> { unscope(where: :account_id) }, class_name: "Character", optional: true

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
  validate :main_character_belongs_to_account

  def default_entry_character_ids
    return [ main_character_id ] if main_character&.account_id == id

    Character.default_entry_character_ids_for(self)
  end

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

  private

  def main_character_belongs_to_account
    return if main_character.blank?
    return if main_character.account_id == id

    errors.add(:main_character, "must belong to this timeline")
  end
end
