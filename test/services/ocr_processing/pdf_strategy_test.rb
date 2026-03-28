require "test_helper"

module OcrProcessing
  class PdfStrategyTest < ActiveSupport::TestCase
    setup do
      Setting.ocr_endpoint = "http://localhost:11434/api/generate"
    end

    test "inherits from BaseStrategy" do
      assert PdfStrategy < BaseStrategy
    end

    test "initializes with image" do
      image = images(:pending_image)
      strategy = PdfStrategy.new(image)

      assert_equal image, strategy.image
      assert_instance_of OcrApiClient, strategy.client
    end

    test "format_page_result formats correctly" do
      image = images(:pending_image)
      strategy = PdfStrategy.new(image)

      result = strategy.send(:format_page_result, 1, "page_1.jpg", "OCR text")

      assert_equal "## ページ 1 (page_1.jpg)\n\nOCR text", result
    end

    test "combine_results joins with separator" do
      image = images(:pending_image)
      strategy = PdfStrategy.new(image)

      results = [ "Page 1 content", "Page 2 content" ]
      combined = strategy.send(:combine_results, results)

      assert_equal "Page 1 content\n\n---\n\nPage 2 content", combined
    end
  end
end
