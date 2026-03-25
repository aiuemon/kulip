class OcrProcessJob < ApplicationJob
  queue_as :default

  retry_on OcrApiClient::TimeoutError, wait: 30.seconds, attempts: 3
  retry_on OcrApiClient::RequestError, wait: 1.minute, attempts: 2
  discard_on OcrApiClient::ConfigurationError
  discard_on PdfProcessingService::PageLimitExceededError

  def perform(image_id)
    image = Image.find_by(id: image_id)
    return unless image
    return unless image.pending?
    return unless image.file.attached?

    if pdf_file?(image)
      process_pdf(image)
    else
      process_image(image)
    end
  end

  private

  def pdf_file?(image)
    image.file.content_type == "application/pdf"
  end

  def process_pdf(image)
    image.update!(status: "processing")

    start_time = Time.current

    pdf_service = PdfProcessingService.new(
      image.file.download,
      image.file.filename.to_s
    )

    page_images = pdf_service.convert_to_images
    client = OcrApiClient.new
    results = []

    page_images.each do |page|
      page_result = client.transcribe(
        image_data: page[:image_data],
        filename: page[:filename],
        content_type: "image/png"
      )
      results << format_page_result(page[:page_number], page[:filename], page_result)
    end

    duration = (Time.current - start_time).to_i
    combined_result = results.join("\n\n---\n\n")

    image.update!(
      status: "completed",
      ocr_result: combined_result,
      ocr_duration: duration,
      ocr_completed_at: Time.current
    )

    send_completion_notification(image)

  rescue PdfProcessingService::Error => e
    Rails.logger.error "PDF processing failed for image #{image.id}: #{e.message}"
    image.update!(status: "failed", ocr_result: "Error: #{e.message}")
    raise
  rescue OcrApiClient::Error => e
    Rails.logger.error "OCR processing failed for image #{image.id}: #{e.message}"
    image.update!(status: "failed", ocr_result: "Error: #{e.message}")
    raise
  end

  def format_page_result(page_number, filename, result)
    "## ページ #{page_number} (#{filename})\n\n#{result}"
  end

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
