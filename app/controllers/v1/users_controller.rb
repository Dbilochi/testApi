class V1::UsersController < V1::BaseController
  require 'json_web_token'

  def index
    if @current_user
      @users =  User.all.select("email, id")
      render json:{
        data:{
          users: @users
        },
        rstatus:0,
        status: 200
      }
    else
      render json:{
        data:{
          users: @user.errors.full_messages
        },
        rstatus:0,
        status: 200
      }
    end
  end
  #
  ## Sign up
  #
  def create
    begin
      @user = User.new(user_create_params)
      @user.confirmation_sent_at = DateTime.current
      if @user.save
        render json: payload_register(@user, "")
      else
        render json:{
          data:{
            messages: @user.errors.full_messages
          },
          rstatus:0,
          status: 404
        }
      end
    rescue Exception => e
      render json:{
        data:{
          messages: e.message
        },
        rstatus:0,
        status: 404
      }
    end
  end


    #
    ## Login
    #
  def login
    begin
      @user = User.find_by(email: params[:email])
        if @user && @user.authenticated(@user.password_digest,params[:password])
          render json: payload(@user, "")
        else
          render json:{errors: ['User not found. Please register.']}, status: :unauthorized
        end
      rescue Exception => e
        render json: {
          data:{
            messages: e.message
          },
          rstatus:0,
          status: 404
        }
      end
    end

    #
    ##confirm
    #

    def confirm
      user =  User.find_by(confirmation_token: params[:confirmation_token])
      if user && (user.confirmation_sent_at > 2.days.ago)
        user.confirmed_at =  DateTime.current
        user.save
        render json:{success: ['User confirmed successfully']}, status: 200
      else
        render json:{errors: ['Confirmation token is invalid']}, status: 404
      end
    end

    private

    def payload_register(user,access_token)
        return nil unless user and user.id
        {
          user: {
            email: user.email,
            confirmation_token: user.confirmation_token
          }
        }
    end

    def payload(user,access_token)
        return nil unless user and user.id
        {
          auth_token: JsonWebToken.encode({user_id: user.id}),
        }
    end

    def user_create_params
      params.require(:user).permit(
      :email,
      :password,
      :password_confirmation
      )
    end
  end
