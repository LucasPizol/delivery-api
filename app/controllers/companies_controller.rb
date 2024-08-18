class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show update destroy ]
  skip_before_action :authenticated, only: %i[index show]
  before_action :authorized, only: %i[update destroy]

  # GET /companies
  def index
    page = params[:page].to_i 
    page = 1 if page <= 0

    per_page = params[:per_page].to_i || 10
    per_page = 10 if per_page <= 0

    offset = (page - 1) * per_page
   
    @companies = Company.all.limit(per_page).offset(offset)

    render json: {
    total: Company.count,    
    data: @companies,
    page: page,
    per_page: per_page
  }
  end

  # GET /companies/1
  def show
    render json: @company
  end

  # POST /companies
  def create
    copy_params = company_params.dup

    copy_params[:cnpj] = copy_params[:cnpj].gsub(/[^0-9]/, '')

    copy_params[:user_id] = @current_user.id

    @company = Company.new(copy_params)

    if @company.save
      render json: @company, status: :created, location: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/1
  def update
    company = Company.find_by(
      id: params[:id],
      user_id: @current_user.id
    )

    if company.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end
    copy_params = company_params.dup

    if company_params[:cnpj]
      copy_params[:cnpj] = company_params[:cnpj].gsub(/[^0-9]/, '')
    end

    if company.update(copy_params)
      render json: company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/1
  def destroy
    company = company = Company.find_by(
      id: params[:id],
      user_id: @current_user.id
    )

    if company.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    company.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.permit(:name, :cnpj, :street, :neighborhood, :city, :state, :description, :number, :complement)
    end
end
