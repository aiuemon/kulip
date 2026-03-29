require "test_helper"

class DownloadContentFormatterTest < ActiveSupport::TestCase
  setup do
    @image = images(:completed_image)
    @image.update_column(:ocr_result, "This is OCR result text")
  end

  test "generates text content by default" do
    formatter = DownloadContentFormatter.new(@image)
    content, filename, content_type = formatter.generate

    assert_equal @image.ocr_result, content
    assert_match(/\.txt$/, filename)
    assert_equal "text/plain", content_type
  end

  test "generates text content for txt format" do
    formatter = DownloadContentFormatter.new(@image, "txt")
    content, filename, content_type = formatter.generate

    assert_equal @image.ocr_result, content
    assert_match(/\.txt$/, filename)
    assert_equal "text/plain", content_type
  end

  test "generates text content for text format" do
    formatter = DownloadContentFormatter.new(@image, "text")
    content, filename, content_type = formatter.generate

    assert_equal @image.ocr_result, content
    assert_match(/\.txt$/, filename)
    assert_equal "text/plain", content_type
  end

  test "generates markdown content for md format" do
    formatter = DownloadContentFormatter.new(@image, "md")
    content, filename, content_type = formatter.generate

    assert_includes content, "# #{@image.name}"
    assert_includes content, @image.ocr_result
    assert_match(/\.md$/, filename)
    assert_equal "text/markdown", content_type
  end

  test "generates markdown content for markdown format" do
    formatter = DownloadContentFormatter.new(@image, "markdown")
    content, filename, content_type = formatter.generate

    assert_includes content, "# #{@image.name}"
    assert_includes content, @image.ocr_result
    assert_match(/\.md$/, filename)
    assert_equal "text/markdown", content_type
  end

  test "falls back to text for unknown format" do
    formatter = DownloadContentFormatter.new(@image, "unknown")
    content, filename, content_type = formatter.generate

    assert_equal @image.ocr_result, content
    assert_match(/\.txt$/, filename)
    assert_equal "text/plain", content_type
  end

  test "uses base name without extension for filename" do
    @image.update_column(:name, "document.png")
    formatter = DownloadContentFormatter.new(@image, "txt")
    _, filename, _ = formatter.generate

    assert_equal "document.txt", filename
  end
end
