class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show update destroy]

  def index
    render json: Company.all
  end

  def show
    render json: @company
  end

  def create
    company = Company.new(company_params)

    if company.save
      render json: company, status: :created
    else
      render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :slug, :contact_email)
  end
end
