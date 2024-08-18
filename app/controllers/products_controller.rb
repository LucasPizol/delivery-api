class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show update destroy ]
  before_action :authorized, only: %i[create update destroy]
  skip_before_action :authenticated, only: %i[show]

  # GET /products/1
  def show
    company_id = params[:company_id]


    products = Product.where(company_id: company_id)

    render json: products
  end

  def index
    company_id = params[:company_id]
    puts company_id

    products = Product.where(company_id: company_id)

    render json: products
  end


  # POST /products
  def create
    company = Company.find_by(id: product_params[:company_id], user_id: @current_user.id)

    if company.nil?
      render json: { error: 'Company not found' }, status: :not_found
      return
    end

    @product = Product.new(product_params)
    

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    product = Product.joins(:company).where(
      id: params[:id],
      companies: { user_id: @current_user.id }
    ).first

    if product.nil?
      render json: { error: 'Not Found' }, status: :not_found
      return
    end

    product.update(update_params)

    render json: product
    return
  end

  # DELETE /products/1
  def destroy
    product = Product.joins(:company).where(
      id: params[:id],
      companies: { user_id: @current_user.id }
    ).first

    if product.nil?
      render json: { error: 'Not Found' }, status: :not_found
      return
    end

    product.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.permit(:name, :description, :price, :picture_url, :company_id, :category)
    end

    def update_params
      params.permit(:name, :description, :price, :picture_url, :category)
    end
end
