class CreditCandidatesController < ApplicationController
  before_action :set_credit
  before_action :set_credit_candidate, only: %i[show edit update destroy]

  def show
  end

  def new
    @credit_candidate = @credit.credit_candidates.build
  end

  def create
    @credit_candidate = @credit.credit_candidates.build(credit_candidate_params)

    if @credit_candidate.save
      redirect_to @credit, notice: "Credit candidate was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @credit_candidate.update(credit_candidate_params)
      redirect_to @credit, notice: "Credit candidate was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @credit_candidate.destroy
    redirect_to @credit, notice: "Credit candidate was successfully removed."
  end

  private

  def set_credit
    @credit = Credit.find(params[:credit_id])
  end

  def set_credit_candidate
    @credit_candidate = @credit.credit_candidates.find(params[:id])
  end

  def credit_candidate_params
    params.require(:credit_candidate).permit(:person_name, :notes, :imdb_url, :image_url, :priority)
  end
end
