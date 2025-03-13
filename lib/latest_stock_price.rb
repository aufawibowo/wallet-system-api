# lib/latest_stock_price.rb
require "net/http"
require "uri"
require "json"

module LatestStockPrice
  API_KEY  = "0a819989fcmshabd0191f215b9bap114b58jsnce2bda0aaebe"
  API_HOST = "latest-stock-price.p.rapidapi.com"

  # 1) price_all -> calls "/any" endpoint, returns an Array of all instruments
  def self.price_all
    url = URI("https://#{API_HOST}/any")
    response_body = fetch_data(url)
    JSON.parse(response_body) # returns an Array of Hashes
  end

  # 2) prices -> calls "/equities" endpoint, returns an Array of equity data
  def self.prices
    url = URI("https://#{API_HOST}/equities")
    response_body = fetch_data(url)
    JSON.parse(response_body) # returns an Array of Hashes
  end

  # 3) price(symbol) -> fetches from "/equities" and filters for the given symbol
  #    Returns a Hash of that symbol's data, or nil if not found.
  def self.price(symbol)
    # For a real single-symbol approach, you’d prefer an endpoint that accepts a symbol param
    # But in this demo, we simply filter the entire equities array.
    all_equities = prices
    # The JSON from "/equities" uses various fields: "NSE Symbol", "Symbol", etc.
    # We'll do a simple match on "Symbol" or "NSE Symbol" if present.
    all_equities.find do |eq|
      eq["Symbol"]&.casecmp(symbol) == 0 || eq["NSE Symbol"]&.casecmp(symbol) == 0
    end
  end

  private

  # Shared method to perform the HTTP GET request with our RapidAPI headers
  def self.fetch_data(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-key"] = API_KEY
    request["x-rapidapi-host"] = API_HOST

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      raise "Error fetching data from #{url}: #{response.code} - #{response.message}"
    end

    response.body
  end
end
