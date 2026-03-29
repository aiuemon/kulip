# OCR 結果のダウンロードコンテンツを生成するサービス
class DownloadContentFormatter
  FORMATS = {
    "md" => :markdown,
    "markdown" => :markdown,
    "txt" => :text,
    "text" => :text
  }.freeze

  attr_reader :image, :format

  def initialize(image, format = "txt")
    @image = image
    @format = format
  end

  # @return [Array<String, String, String>] [content, filename, content_type]
  def generate
    case format_type
    when :markdown
      markdown_content
    else
      text_content
    end
  end

  private

  def format_type
    FORMATS[format] || :text
  end

  def base_name
    File.basename(image.name, ".*")
  end

  def markdown_content
    content = "# #{image.name}\n\n#{image.ocr_result}"
    [ content, "#{base_name}.md", "text/markdown" ]
  end

  def text_content
    [ image.ocr_result, "#{base_name}.txt", "text/plain" ]
  end
end
