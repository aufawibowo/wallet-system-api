class HealthcheckController < ActionController::API
  def index
    render json: { status: "healthy :strong" }
  end
end
