class OrderProductsController < ApplicationController
  def index
    if !params[:order_id]
      render json: { error: 'Order ID is required' }, status: :bad_request
      return
    end

    @order_products = OrderProduct
    .joins(:product)
    .where(
          product: { company_id: @current_user.company_id },
          order_id: params[:order_id]
        )

    render json: @order_products
  end

  def show
    render status: :not_found
  end

  def create
    copy_params = order_product_params.dup

    find_order = Order.find_by(id: copy_params[:order_id], company_id: @current_user.company_id)

    if find_order.nil?
      render json: { error: 'Order not found' }, status: :not_found
      return
    end

    @order_product = OrderProduct.new(order_product_params)

    if @order_product.save
      render json: @order_product, status: :created, location: @order_product
    else
      render json: @order_product.errors, status: :unprocessable_entity
    end
  end

  def update
    order_product = OrderProduct
    .joins(:product)
    .where(
      product: { company_id: @current_user.company_id },
      id: params[:id]
    ).first
    
    if order_product.update(update_order_params)
      render json: order_product
    else
      render json: @order_product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    order_product = OrderProduct
    .joins(:product)
    .where(
      product: { company_id: @current_user.company_id },
      id: params[:id]
    ).first

    order_product.destroy!
  end

  private
    def update_order_params
      params.require(:order_product).permit(:quantity, :unit_price)
    end

    def order_product_params
      params.require(:order_product).permit(:quantity, :unit_price, :product_id, :order_id)
    end
end
