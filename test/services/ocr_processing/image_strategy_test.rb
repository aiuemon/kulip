require "test_helper"

module OcrProcessing
  class ImageStrategyTest < ActiveSupport::TestCase
    setup do
      Setting.ocr_endpoint = "http://localhost:11434/api/generate"
    end

    test "inherits from BaseStrategy" do
      assert ImageStrategy < BaseStrategy
    end

    test "initializes with image" do
      image = images(:pending_image)
      strategy = ImageStrategy.new(image)

      assert_equal image, strategy.image
      assert_instance_of OcrApiClient, strategy.client
    end
  end
end
