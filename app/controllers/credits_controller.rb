class CreditsController < ApplicationController
  before_action :require_write_access, except: %i[index show]
  before_action :set_credit, only: %i[show edit update destroy]

  def index
    @credits = Credit.by_priority.includes(:credit_candidates)
  end

  def show
    @credit_candidates = @credit.credit_candidates.by_priority
  end

  def new
    @credit = Credit.new
  end

  def create
    @credit = Credit.new(credit_params)

    if @credit.save
      redirect_to @credit, notice: "Credit was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @credit.update(credit_params)
      redirect_to @credit, notice: "Credit was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @credit.destroy
    redirect_to credits_url, notice: "Credit was successfully deleted."
  end

  private

  def set_credit
    @credit = Credit.find(params[:id])
  end

  def credit_params
    params.require(:credit).permit(:title, :description, :priority)
  end
end
