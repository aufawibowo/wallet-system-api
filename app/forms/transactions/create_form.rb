# app/forms/transactions/create_form.rb
module Transactions
  class CreateForm
    include ActiveModel::Model

    attr_reader :source_wallet, :target_wallet, :amount, :error_message

    def initialize(params = {})
      @params = params
    end

    # Main entry point to perform the transaction
    def create
      create_transaction
      true
    rescue => e
      # If an error or Rollback is raised, capture the message and return false
      @error_message = e.message
      false
    end

    # Return a success payload that the controller can render
    def success_response
      {
        message: "Transaction successful",
        source_wallet_id: @source_wallet.id,
        target_wallet_id: @target_wallet.id,
        amount: @amount.to_s
      }
    end

    private

    def create_transaction
      # 1) Parse and fetch required params
      @source_wallet = Wallet.find(@params[:source_wallet_id])
      @target_wallet = Wallet.find(@params[:target_wallet_id])
      @amount        = BigDecimal(@params[:amount])

      # (Optional) authorization logic:
      # if @source_wallet.owner != @current_user
      #   raise "You do not have permission to debit this wallet"
      # end

      # 2) Atomic transaction with row locking
      ActiveRecord::Base.transaction do
        lock_wallets_in_order!(@source_wallet, @target_wallet)

        # 3) Ensure no negative balance
        if @source_wallet.balance < @amount
          raise ActiveRecord::Rollback, "Insufficient funds in source wallet"
        end

        # 4) Adjust balances
        @source_wallet.update!(balance: @source_wallet.balance - @amount)
        @target_wallet.update!(balance: @target_wallet.balance + @amount)

        # 5) Record the transaction in the ledger
        Transaction.create!(
          source_wallet_id: @source_wallet.id,
          target_wallet_id: @target_wallet.id,
          amount: @amount
        )
      end
    end

    def lock_wallets_in_order!(wallet_a, wallet_b)
      # To avoid potential deadlock, always lock the lower ID first
      if wallet_a.id < wallet_b.id
        wallet_a.lock!
        wallet_b.lock!
      else
        wallet_b.lock!
        wallet_a.lock!
      end
    end
  end
end
