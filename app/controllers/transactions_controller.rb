# app/controllers/transactions_controller.rb
class TransactionsController < ApplicationController
  def create
    create_form = Transactions::CreateForm.new(params)

    if create_form.create
      render json: create_form.success_response, status: :created
    else
      render json: { error: create_form.error_message }, status: :unprocessable_entity
    end
  rescue => e
    # In case of any unexpected exception not handled inside the form
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
