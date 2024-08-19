class AddressesController < ApplicationController
  before_action :set_address, only: %i[ show update destroy ]

  # GET /addresses
  def index
    @addresses = Address.where(user_id: @current_user.id)

    render json: @addresses
  end

  # GET /addresses/1
  def show
    render json: @address
  end

  # POST /addresses
  def create
    copy_params = address_params.dup
    @address = Address.new(format_params)

    if @address.save
      render json: @address, status: :created, location: @address
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /addresses/1
  def update
    if @address.update(format_params)
      render json: @address
    else
      render json: @address.errors, status: :unprocessable_entity
    end
  end

  # DELETE /addresses/1
  def destroy
    @address.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address
      Address.where(id: params[:id], user_id: @current_user.id)
    end

    # Only allow a list of trusted parameters through.
    def address_params
      params.permit(:city, :number, :complement, :street, :zip_code, :state)
    end

    def format_params
      copy_params = address_params.dup
      copy_params[:state] = copy_params[:state].upcase if copy_params[:state]
      copy_params[:zip_code] = copy_params[:zip_code].gsub(/[^0-9]/, '') if copy_params[:zip_code]
      copy_params[:user_id] = @current_user.id
      return copy_params
    end
end
