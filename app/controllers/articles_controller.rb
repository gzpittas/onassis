class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]

  def index
    @articles = Article.by_date.includes(:entries, :characters)
  end

  def show
  end

  def new
    @article = Article.new
    @entries = Entry.chronological
    @characters = Character.by_name
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article, notice: "Article was successfully created."
    else
      @entries = Entry.chronological
      @characters = Character.by_name
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @entries = Entry.chronological
    @characters = Character.by_name
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "Article was successfully updated."
    else
      @entries = Entry.chronological
      @characters = Character.by_name
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, notice: "Article was successfully deleted."
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :publication, :author, :publication_date,
                                    :url, :notes, entry_ids: [], character_ids: [])
  end
end
