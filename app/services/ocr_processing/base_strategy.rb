module OcrProcessing
  # OCR 処理の基底クラス
  # Template Method パターンで共通処理を提供し、サブクラスで具体的な処理を実装
  class BaseStrategy
    attr_reader :image, :client

    def initialize(image, client = nil)
      @image = image
      @client = client || OcrApiClient.new
    end

    # メインの処理メソッド
    # サブクラスは execute_ocr を実装する
    def process
      image.update!(status: "queued")
      start_time = Time.current

      result = execute_ocr

      duration = (Time.current - start_time).to_i
      complete_processing(result, duration)
      send_completion_notification
    rescue StandardError => e
      handle_error(e)
      raise
    end

    private

    # サブクラスで実装する OCR 処理
    # @return [String] OCR 結果
    def execute_ocr
      raise NotImplementedError, "#{self.class} must implement #execute_ocr"
    end

    # API 呼び出し前にステータスを processing に更新
    def mark_processing!
      image.update!(status: "processing")
    end

    def complete_processing(result, duration)
      image.update!(
        status: "completed",
        ocr_result: result,
        ocr_duration: duration,
        ocr_completed_at: Time.current
      )
    end

    def handle_error(error)
      error_type = error.class.name.split("::").last
      Rails.logger.error "#{error_type} for image #{image.id}: #{error.message}"
      image.update!(status: "failed", ocr_result: "Error: #{error.message}")
    end

    def send_completion_notification
      return unless Setting.notification_email_enabled?

      OcrCompletionMailer.completion_notification(image).deliver_later
    rescue StandardError => e
      Rails.logger.error "Failed to send completion notification for image #{image.id}: #{e.message}"
    end
  end
end
