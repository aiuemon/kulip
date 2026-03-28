module OcrProcessing
  # 通常画像（JPEG, PNG, HEIC 等）の OCR 処理
  class ImageStrategy < BaseStrategy
    private

    def execute_ocr
      image_data, filename, content_type = prepare_image_data
      client.transcribe(
        image_data: image_data,
        filename: filename,
        content_type: content_type
      )
    end

    def prepare_image_data
      original_data = image.file.download
      original_filename = image.file.filename.to_s
      original_content_type = image.file.content_type

      if HeicProcessingService.heic?(original_content_type)
        convert_heic(original_data, original_filename)
      else
        [ original_data, original_filename, original_content_type ]
      end
    end

    def convert_heic(data, filename)
      service = HeicProcessingService.new(data, filename)
      converted = service.convert_to_png
      [ converted[:image_data], converted[:filename], converted[:content_type] ]
    end
  end
end
