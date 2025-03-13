# app/forms/transactions/create_form.rb
module Transactions
  class CreateForm
    include ActiveModel::Model

    attr_accessor :sender_id, :receiver_id, :amount
    attr_reader :error_message

    def process_transfer
      ActiveRecord::Base.transaction do
        load_entities

        # Lock them in consistent order to avoid deadlock
        lock_entities_in_order(@sender, @receiver)

        validate_funds!
        create_double_entry_rows!
        create_wallet_snapshots!
      end
      true
    rescue => e
      @error_message = e.message
      false
    end

    def success_response
      {
        message:          "Transfer successful",
        sender_balance:   @sender.wallets.order(created_at: :desc).first.balance,
        receiver_balance: @receiver.wallets.order(created_at: :desc).first.balance
      }
    end

    private

    def load_entities
      @sender   = User.find(sender_id)
      @receiver = User.find(receiver_id)
      @amount   = BigDecimal(amount.to_s)
    end

    def lock_entities_in_order(user_a, user_b)
      if user_a.id < user_b.id
        user_a.lock!
        user_b.lock!
      else
        user_b.lock!
        user_a.lock!
      end
    end

    def validate_funds!
      current_balance = @sender.wallets.order(created_at: :desc).first&.balance || 0
      raise "Insufficient funds" if current_balance < @amount
    end

    def create_double_entry_rows!
      # 1) Sender: Debit
      Transaction.create!(
        user_id: @sender.id,
        debit:   @amount,
        credit:  0,
        description: "Transfer to user##{@receiver.id}"
      )

      # 2) Receiver: Credit
      Transaction.create!(
        user_id: @receiver.id,
        debit:   0,
        credit:  @amount,
        description: "Transfer from user##{@sender.id}"
      )
    end

    def create_wallet_snapshots!
      # Recompute fresh balances
      sender_new_balance   = compute_balance(@sender) - @amount
      receiver_new_balance = compute_balance(@receiver) + @amount

      @sender.wallets.create!(
        balance: sender_new_balance,
        reason:  "Transfer to user##{@receiver.id}"
      )

      @receiver.wallets.create!(
        balance: receiver_new_balance,
        reason:  "Transfer from user##{@sender.id}"
      )
    end

    def compute_balance(user)
      user.wallets.order(created_at: :desc).first&.balance || 0
    end
  end
end
