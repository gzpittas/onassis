class ArticleCharacter < ApplicationRecord
  belongs_to :article
  belongs_to :character

  validates :character_id, uniqueness: { scope: :article_id }
end
