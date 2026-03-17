require "net/http"
require "uri"
require "json"

class OcrApiClient
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class RequestError < Error; end
  class TimeoutError < Error; end

  DEFAULT_TIMEOUT = 60

  def initialize
    @endpoint = ENV.fetch("OCR_API_ENDPOINT") { raise ConfigurationError, "OCR_API_ENDPOINT is not set" }
    @api_key = ENV.fetch("OCR_API_KEY") { raise ConfigurationError, "OCR_API_KEY is not set" }
    @timeout = ENV.fetch("OCR_API_TIMEOUT", DEFAULT_TIMEOUT).to_i
  end

  # 画像を送信して OCR 結果を取得
  # @param image_data [String] 画像のバイナリデータ
  # @param filename [String] ファイル名
  # @param content_type [String] Content-Type
  # @return [Hash] OCR 結果
  def transcribe(image_data:, filename:, content_type:)
    uri = URI.parse(@endpoint)
    http = build_http_client(uri)

    request = build_multipart_request(uri, image_data, filename, content_type)
    response = execute_request(http, request)

    parse_response(response)
  end

  # API の設定が有効かどうかを確認
  def self.configured?
    ENV["OCR_API_ENDPOINT"].present? && ENV["OCR_API_KEY"].present?
  end

  private

  def build_http_client(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = @timeout
    http.read_timeout = @timeout
    http
  end

  def build_multipart_request(uri, image_data, filename, content_type)
    boundary = "----RubyFormBoundary#{SecureRandom.hex(16)}"

    body = build_multipart_body(boundary, image_data, filename, content_type)

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
    request["Authorization"] = "Bearer #{@api_key}"
    request["Accept"] = "application/json"
    request.body = body

    request
  end

  def build_multipart_body(boundary, image_data, filename, content_type)
    body = +""
    body << "--#{boundary}\r\n"
    body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n"
    body << "Content-Type: #{content_type}\r\n"
    body << "\r\n"
    body << image_data
    body << "\r\n"
    body << "--#{boundary}--\r\n"
    body
  end

  def execute_request(http, request)
    http.request(request)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise TimeoutError, "API request timed out: #{e.message}"
  rescue StandardError => e
    raise RequestError, "API request failed: #{e.message}"
  end

  def parse_response(response)
    case response.code.to_i
    when 200..299
      JSON.parse(response.body, symbolize_names: true)
    when 401
      raise RequestError, "Authentication failed: Invalid API key"
    when 404
      raise RequestError, "API endpoint not found"
    when 429
      raise RequestError, "Rate limit exceeded"
    when 500..599
      raise RequestError, "API server error: #{response.code}"
    else
      raise RequestError, "Unexpected response: #{response.code} - #{response.body}"
    end
  end
end
