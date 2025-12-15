class Source < ApplicationRecord
  has_many :entries, dependent: :nullify # Legacy association
  has_many :entry_sources, dependent: :destroy
  has_many :cited_entries, through: :entry_sources, source: :entry
  has_many :source_links, dependent: :destroy

  accepts_nested_attributes_for :source_links, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true

  SOURCE_TYPES = %w[book newspaper magazine documentary interview archive website other].freeze

  validates :source_type, inclusion: { in: SOURCE_TYPES }, allow_blank: true

  scope :books, -> { where(source_type: "book") }
  scope :articles, -> { where(source_type: %w[newspaper magazine]) }

  def display_name
    author.present? ? "#{title} (#{author})" : title
  end
end
