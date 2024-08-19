class OrdersController < ApplicationController
  def company_orders
    page = params[:page].to_i 
    page = 1 if page <= 0

    per_page = params[:per_page].to_i || 10
    per_page = 10 if per_page <= 0

    offset = (page - 1) * per_page
   
    orders = Order.where(
      company_id: @current_user.company_id
    ).limit(per_page).offset(offset)
    render json: orders
  end

  def index
    if params[:company_id]
      @orders = Order.where(company_id: params[:company_id], user_id: @current_user.id)
    else
      set_order_by_user
    end

    render json: @orders
  end

  def show
    order = Order.find_by(id: params[:id], user_id: @current_user.id)

    render json: order
  end

  def create
    if order_params[:products].length == 0
      render json: { error: 'Order must have at least one product' }, status: :unprocessable_entity
      return
    end

    if order_params[:address_id].nil?
      render json: { error: 'Order must have an address' }, status: :unprocessable_entity
      return
    end

    copy_order_params = order_params.dup
    copy_order_params[:user_id] = @current_user.id
    copy_order_params[:finished_at] = nil
    copy_order_params[:status] = 'pending'
    copy_order_params[:company_id] = order_params[:company_id]

    copy_order_params.delete(:products)
     
    @order = Order.new(copy_order_params)

    products = Product.where(id: order_params[:products].map { |product| product[:product_id] })

    if (products.length < order_params[:products].length) 
      @order.destroy
      render json: { error: 'One of the products was not found in the company' }, status: :not_found
      return
    end

    if @order.save

      products.each do |product|
        find_product = order_params[:products].find { |p| p[:product_id] == product.id }
        puts find_product
  
        OrderProduct.create(order_id: @order.id, product_id: product.id, quantity: find_product[:quantity], unit_price: product.price )
      end


      render json: @order, status: :created, location: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def update
    order = Order.find_by(id: params[:id], company_id: @current_user.company_id)


    if order.update(order_params)
      render json: order
    else
      render json: order.errors, status: :unprocessable_entity
    end
  end

  def destroy
    order = Order.find_by(id: params[:id], company_id: @current_user.company_id)

    order.destroy!
  end

  private
    def order_params
      params.permit(:observation, :status, :company_id, :address_id, products: [:product_id, :quantity])
    end
end
