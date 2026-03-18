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

    client = OcrApiClient.new
    result = client.transcribe(
      image_data: image.file.download,
      filename: image.file.filename.to_s,
      content_type: image.file.content_type
    )

    # OcrApiClient#transcribe は既にテキストを返す
    image.update!(status: "completed", ocr_result: result)

  rescue OcrApiClient::Error => e
    Rails.logger.error "OCR processing failed for image #{image.id}: #{e.message}"
    image.update!(status: "failed", ocr_result: "Error: #{e.message}")
    raise
  end
end
