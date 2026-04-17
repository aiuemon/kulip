module OcrProcessing
  # PDF ファイルの OCR 処理
  # PDF を画像に変換し、各ページを OCR 処理して結果を結合
  class PdfStrategy < BaseStrategy
    private

    def execute_ocr
      page_images = convert_pdf_to_images
      mark_processing!
      results = process_pages(page_images)
      combine_results(results)
    end

    def convert_pdf_to_images
      pdf_service = PdfProcessingService.new(
        image.file.download,
        image.file.filename.to_s
      )
      pdf_service.convert_to_images
    end

    def process_pages(page_images)
      prompt = image.effective_ocr_prompt
      page_images.map do |page|
        page_result = client.transcribe(
          image_data: page[:image_data],
          filename: page[:filename],
          content_type: "image/jpeg",
          prompt: prompt
        )
        format_page_result(page[:page_number], page[:filename], page_result)
      end
    end

    def format_page_result(page_number, filename, result)
      "## ページ #{page_number} (#{filename})\n\n#{result}"
    end

    def combine_results(results)
      results.join("\n\n---\n\n")
    end
  end
end
