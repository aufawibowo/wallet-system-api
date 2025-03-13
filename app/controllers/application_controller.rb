class ApplicationController < ActionController::API
  protect_from_forgery with: :null_session  # For API use-cases

  before_action :authorize_request

  def authorize_request
    header = request.headers["Authorization"]
    if header.present? && header.match(/^Bearer /)
      token = header.split(" ").last
      user_id = AuthController::TOKEN_STORE[token]
      if user_id
        @current_user = User.find_by(id: user_id)
      end
    end

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
