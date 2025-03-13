# app/models/transaction.rb
class Transaction < ApplicationRecord
  belongs_to :user

  validates :debit,  numericality: { greater_than_or_equal_to: 0 }
  validates :credit, numericality: { greater_than_or_equal_to: 0 }
end
