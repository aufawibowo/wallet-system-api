# app/controllers/transactions_controller.rb
class TransactionsController < ApplicationController
  def create
    form = Transactions::CreateForm.new(
      sender_id: @current_user.id,
      receiver_id: params[:receiver_id],
      amount: params[:amount]
    )

    if form.process_transfer
      render json: form.success_response, status: :created
    else
      render json: { error: form.error_message }, status: :unprocessable_entity
    end
  end
end
