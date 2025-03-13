class StockPriceLog < ApplicationRecord
  belongs_to :user, optional: true  # If not always required
  # store symbol, price
end
