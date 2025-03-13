# app/models/user.rb
class User < ApplicationRecord
  # We do a naive password approach (manually or by a hashing library).

  has_secure_password
  has_many :transactions
  has_many :wallets

  def current_balance
    # fetch the latest wallet record
    wallets.order(created_at: :desc).first&.balance || 0
  end
end
