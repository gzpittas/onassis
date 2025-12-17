class Article < ApplicationRecord
  has_many :entry_articles, dependent: :destroy
  has_many :entries, through: :entry_articles
  has_many :article_characters, dependent: :destroy
  has_many :characters, through: :article_characters

  validates :title, presence: true
  validates :url, presence: true

  scope :by_date, -> { order(publication_date: :desc) }
  scope :by_title, -> { order(:title) }

  def display_name
    publication.present? ? "#{title} (#{publication})" : title
  end
end
