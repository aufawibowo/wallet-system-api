# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  # For the sake of an MVP, store tokens in a simple in-memory hash.
  TOKEN_STORE = {}

  def login
    # Expect params[:email] and params[:password]
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      # Generate a random token
      token = SecureRandom.hex(20)

      # Store a mapping token => user_id (or user object)
      TOKEN_STORE[token] = user.id

      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end
