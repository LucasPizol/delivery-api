class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]
  skip_before_action :authenticated, only: %i[login create]

  def login 
    user = nil

    if params[:usernameOrEmail].include?('@')
      user = User.find_by(email: params[:usernameOrEmail])
    else
      user = User.find_by(username: params[:usernameOrEmail])
    end

    if !user
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    if user.authenticate(params[:password])
      token = JwtService.encode({ id: user.id })

      render json: { 
        id: user.id,
        username: user.username,
        email: user.email,
        name: user.name,
        role: user.role,
        token: token
      }
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end


  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    copy_user_params = user_params.dup

    copy_user_params[:phone] = user_params[:phone]
                              .gsub(/[^0-9]/, '')
                              .gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')

    copy_user_params[:cpf] = user_params[:cpf]
                            .gsub(/[^0-9]/, '')

    @user = User.new(copy_user_params)
    
    if @user.save
      token = JwtService.encode({ id: @user.id })

      render json: { 
        id: @user.id,
        username: @user.username,
        email: @user.email,
        name: @user.name,
        role: @user.role,
        token: token
      }, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.permit(:username, :email, :name, :role, :password, :password_confirmation, :cpf, :phone)
    end
end
