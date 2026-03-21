class OcrProcessJob < ApplicationJob
  queue_as :default

  retry_on OcrApiClient::TimeoutError, wait: 30.seconds, attempts: 3
  retry_on OcrApiClient::RequestError, wait: 1.minute, attempts: 2
  discard_on OcrApiClient::ConfigurationError

  def perform(image_id)
    image = Image.find_by(id: image_id)
    return unless image
    return unless image.pending?
    return unless image.file.attached?

    process_image(image)
  end

  private

  def process_image(image)
    image.update!(status: "processing")

    start_time = Time.current

    client = OcrApiClient.new
    result = client.transcribe(
      image_data: image.file.download,
      filename: image.file.filename.to_s,
      content_type: image.file.content_type
    )

    duration = (Time.current - start_time).to_i

    image.update!(
      status: "completed",
      ocr_result: result,
      ocr_duration: duration,
      ocr_completed_at: Time.current
    )

    send_completion_notification(image)

  rescue OcrApiClient::Error => e
    Rails.logger.error "OCR processing failed for image #{image.id}: #{e.message}"
    image.update!(status: "failed", ocr_result: "Error: #{e.message}")
    raise
  end

  def send_completion_notification(image)
    return unless Setting.notification_email_enabled?

    OcrCompletionMailer.completion_notification(image).deliver_later
  rescue StandardError => e
    Rails.logger.error "Failed to send completion notification for image #{image.id}: #{e.message}"
  end
end
