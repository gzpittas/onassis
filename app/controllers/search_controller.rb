class SearchController < ApplicationController
  def index
    @query = params[:q]

    if @query.present?
      search_term = "%#{@query.downcase}%"

      @entries = Entry.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(location) LIKE ? OR LOWER(significance) LIKE ?",
        search_term, search_term, search_term, search_term
      ).chronological.includes(:source, :characters).limit(50)

      @characters = Character.where(
        "LOWER(name) LIKE ? OR LOWER(bio) LIKE ? OR LOWER(occupation) LIKE ?",
        search_term, search_term, search_term
      ).by_name.limit(20)

      @sources = Source.where(
        "LOWER(title) LIKE ? OR LOWER(author) LIKE ? OR LOWER(notes) LIKE ?",
        search_term, search_term, search_term
      ).order(:title).limit(20)
    else
      @entries = Entry.none
      @characters = Character.none
      @sources = Source.none
    end
  end
end
