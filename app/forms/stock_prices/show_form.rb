# app/forms/stock_prices/show_form.rb
module StockPrices
  class ShowForm
    include ActiveModel::Model

    attr_accessor :symbol, :current_user
    attr_reader :price_data, :error_message

    def initialize(attributes = {})
      super
      # symbol (string) and current_user (User instance) assigned by ActiveModel::Model
    end

    # Main method to fetch the stock price data
    def fetch
      # 1) Call the RapidApi service to get data for the symbol
      data = fetch_stock_price_from_api(symbol)

      # 2) Return false if data is missing or if we encountered an error
      unless data
        @error_message = "No data found for symbol: #{symbol}"
        return false
      end

      # 3) Log the request (if you wish)
      log_stock_price(data)

      # 4) Store the data in instance variable for success_response
      @price_data = data
      true
    rescue => e
      @error_message = e.message
      false
    end

    # Called by the controller upon success
    def success_response
      # You can adapt the structure as needed.
      {
        symbol: symbol,
        price_data: price_data
      }
    end

    private

    # Use your custom RapidApi::LatestStockPriceService to fetch the symbol
    def fetch_stock_price_from_api(symbol)
      service = RapidApi::LatestStockPriceService.new({})
      # Example using .price(symbol):
      service.price(symbol)
      # => returns a Hash or nil
    end

    # Log in the DB that @current_user requested the price
    def log_stock_price(data)
      StockPriceLog.create!(
        user: current_user,
        symbol: data["Symbol"] || data["NSE Symbol"] || symbol,
        price: data["LTP"] || 0
      )
    end
  end
end
