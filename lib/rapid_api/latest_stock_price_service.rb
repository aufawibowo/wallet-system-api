# lib/rapid_api/latest_stock_price_service.rb
require_relative "request_service"

module RapidApi
  class LatestStockPriceService < RequestService
    # We override set_header to add RapidAPI-specific headers
    private def set_header
      super  # Call parent's set_header for possible Authorization
      @req["x-rapidapi-key"]  = ENV.fetch("RAPIDAPI_KEY", "")
      @req["x-rapidapi-host"] = "latest-stock-price.p.rapidapi.com"
    end

    # 1) price_all -> calls "/any" endpoint
    # returns the array of all instruments on success, or false on error
    def price_all
      @params[:request_path]   = "/any"
      @params[:request_method] = "get"

      success = call
      return false if !success || error.present?

      result  # from parent; the parsed JSON array
    end

    # 2) prices -> calls "/equities" endpoint
    # returns the array of equity data on success, or false on error
    def prices
      @params[:request_path]   = "/equities"
      @params[:request_method] = "get"

      success = call
      return false if !success || error.present?

      result  # the parsed JSON array
    end

    # 3) price(symbol) -> fetches from "/equities" then filters the returned array
    # returns a Hash of the matching equity or nil if not found
    def price(symbol)
      data = prices
      return false if data == false  # means error fetching

      # Example logic: check "Symbol" or "NSE Symbol"
      data.find do |eq|
        eq["Symbol"]&.casecmp(symbol) == 0 || eq["NSE Symbol"]&.casecmp(symbol) == 0
      end
    end
  end
end
