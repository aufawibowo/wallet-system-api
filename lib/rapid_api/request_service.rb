# lib/rapid_api/request_service.rb
require "net/http"
require "json"

module RapidApi
  class RequestService
    attr_reader :error, :result, :response, :code

    def initialize(params)
      @params = params
      # e.g. ENV['URL'] = "https://latest-stock-price.p.rapidapi.com"
      @url = "#{ENV.fetch('URL')}#{@params[:request_path]}"
      @uri = URI(@url)
    end

    def call
      call_request
      handle_response
      return false if @error.present?

      @result = @response_body
      true
    rescue StandardError => e
      @error = e.message
      false
    end

    private

    def call_request
      generate_request
      set_header
      req_body
      @response = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: true) do |http|
        http.request(@req)
      end
    end

    # By default, we only set an Authorization header if provided,
    # but child classes can override or extend this method.
    def set_header
      return if @params[:access_token].blank?

      @req["Authorization"] = "Bearer #{@params[:access_token]}"
    end

    def req_body
      return unless @params[:body_request].present?

      @req.set_form_data(@params[:body_request])
    end

    def generate_request
      @req = case @params[:request_method].to_s.downcase
      when "POST"
               Net::HTTP::Post.new(@uri)
      when "PUT"
               Net::HTTP::Put.new(@uri)
      when "DELETE"
               Net::HTTP::Delete.new(@uri)
      else
               Net::HTTP::Get.new(@uri)
      end
    end

    def handle_response
      # Parse response body as JSON if present
      @response_body = @response.body.present? ? JSON.parse(@response.body) : {}
      @code = @response.code.to_i

      case @code
      when 200..299
        # Successful response, do nothing special
      when 404
        @error = "Not found (404)"
      else
        # Attempt to find any error message in the JSON body
        msg = @response_body["error_description"] || @response_body["message"] ||
          @response_body["errors"] || "Unknown error"
        @error = "#{msg} (#{@code})"
      end
    end
  end
end
