require "net/http"
require "uri"
require "json"
require "base64"

class OcrApiClient
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class RequestError < Error; end
  class TimeoutError < Error; end

  def initialize
    @endpoint = OcrSetting.ocr_endpoint
    @api_key = OcrSetting.ocr_api_key
    @timeout = OcrSetting.ocr_timeout

    raise ConfigurationError, "OCR API endpoint is not configured" if @endpoint.blank?
  end

  # 画像を送信して OCR 結果を取得
  # @param image_data [String] 画像のバイナリデータ
  # @param filename [String] ファイル名（未使用だが互換性のため残す）
  # @param content_type [String] Content-Type（未使用だが互換性のため残す）
  # @return [String] OCR 結果テキスト
  def transcribe(image_data:, filename: nil, content_type: nil)
    uri = URI.parse(@endpoint)
    http = build_http_client(uri)

    request = build_json_request(uri, image_data)
    response = execute_request(http, request)

    parse_response(response)
  end

  # API の設定が有効かどうかを確認
  def self.configured?
    OcrSetting.configured?
  end

  private

  def build_http_client(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = @timeout
    http.read_timeout = @timeout
    http
  end

  def build_json_request(uri, image_data)
    image_b64 = Base64.strict_encode64(image_data)

    payload = {
      model: OcrSetting.ocr_model,
      prompt: OcrSetting.ocr_prompt,
      images: [ image_b64 ],
      stream: false,
      options: OcrSetting.ocr_options
    }

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{@api_key}" if @api_key.present?
    request.body = payload.to_json

    request
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
      data = JSON.parse(response.body, symbolize_names: true)
      extract_text(data)
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

  # レスポンスからテキストを抽出
  # <think>...</think> タグを除去して最終的なテキストを返す
  def extract_text(data)
    text = data[:response] || data[:text] || data[:content] || ""

    # <think>...</think> タグを除去
    text = text.gsub(%r{<think>.*?</think>}m, "").strip

    text
  end
end
