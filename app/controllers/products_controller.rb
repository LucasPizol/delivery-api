class ProductsController < ApplicationController
  before_action :set_product, only: %i[update destroy]
  before_action :authorized, only: %i[create update destroy]
  skip_before_action :authenticated, only: %i[show]

  # GET /products/1
  def show
    render status: :not_found
  end

  def index
    company_id = params[:company_id]

    products = Product.where(company_id: company_id)

    render json: products
  end

  def list_company_products
    products = Product.where(company_id: @current_user.company_id)
    render json: products
  end


  # POST /products
  def create
    copy_params = product_params.dup
    copy_params[:company_id] = @current_user.company_id

    if copy_params[:picture] 
      picture = product_params[:picture]

      aws_service = AwsService.new
      extension = File.extname(picture.original_filename)
      now = Time.now.strftime("%d%m%Y")

      url = aws_service.insert(picture, "products/#{copy_params[:name].parameterize}/#{picture.original_filename.gsub(extension, "").parameterize}-#{now}#{extension}")
      copy_params[:picture_url] = url
    
    end

    copy_params.delete(:picture)

    product = Product.new(copy_params)
    
    if product.save
      render json: product, status: :created, location: @product
    else
      render json: product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.nil?
      render json: { error: 'Not Found' }, status: :not_found
      return
    end

    @product.update(update_params)

    render json: @product
    return
  end

  # DELETE /products/1
  def destroy
    if @product.nil?
      render json: { error: 'Not Found' }, status: :not_found
      return
    end

    @product.destroy!
  end

  private
    def set_product
      @product = Product.joins(:company).where(
        id: params[:id],
        company_id: @current_user.company_id
      ).first
    end

    def product_params
      params.permit(:name, :description, :price, :picture_url, :company_id, :category, :picture)
    end

    def update_params
      params.permit(:name, :description, :price, :picture_url, :category)
    end
end
