# app/controllers/stock_prices_controller.rb
class StockPricesController < ApplicationController
  # GET /stock_prices/:symbol
  def show
    # Instantiate the form object with the symbol param and the current_user
    form = StockPrices::ShowForm.new(symbol: params[:symbol], current_user: @current_user)

    if form.fetch
      # If fetch == true, render the success payload
      render json: form.success_response, status: :ok
    else
      # On failure, render the error message
      render json: { error: form.error_message }, status: :unprocessable_entity
    end
  rescue => e
    # Catch any unforeseen errors that might escape the form’s rescue
    render json: { error: e.message }, status: :internal_server_error
  end
end
