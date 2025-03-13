class Transaction < ApplicationRecord
  belongs_to :source_wallet, class_name: "Wallet"
  belongs_to :target_wallet, class_name: "Wallet"

  validates :amount, presence: true, numericality: { greater_than: 0 }

  # def self.perform(source:, target:, amount:)
  #   Wallet.transaction do
  #     source.lock!
  #     target.lock!
  #
  #     # Validate no negative results
  #     if source.balance < amount
  #       raise ActiveRecord::Rollback, "Insufficient funds"
  #     end
  #
  #     source.update!(balance: source.balance - amount)
  #     target.update!(balance: target.balance + amount)
  #
  #     # Record the transaction
  #     Transaction.create!(
  #       source_wallet: source,
  #       target_wallet: target,
  #       amount: amount
  #     )
  #   end
  # end
end
