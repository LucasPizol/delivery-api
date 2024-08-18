class ApplicationController < ActionController::API
  before_action :authenticated

  def authenticated
    if request.headers['Authorization']
      token = request.headers['Authorization'].split(' ').last
      decoded_token = JwtService.decode(token)
      puts decoded_token

      @current_user = User.find(decoded_token.first['id'])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def authorized

    if @current_user.nil?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end  

    if @current_user.role != 'ADMIN'
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
