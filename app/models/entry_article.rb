class EntryArticle < ApplicationRecord
  belongs_to :entry
  belongs_to :article

  validates :article_id, uniqueness: { scope: :entry_id }
end
