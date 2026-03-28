require "test_helper"

module OcrProcessing
  class BaseStrategyTest < ActiveSupport::TestCase
    setup do
      # OCR API 設定をセットアップ
      Setting.ocr_endpoint = "http://localhost:11434/api/generate"
    end

    test "raises NotImplementedError when execute_ocr is not implemented" do
      image = images(:pending_image)
      strategy = BaseStrategy.new(image)

      assert_raises(NotImplementedError) do
        strategy.send(:execute_ocr)
      end
    end

    test "accepts custom client" do
      image = images(:pending_image)
      custom_client = OcrApiClient.new
      strategy = BaseStrategy.new(image, custom_client)

      assert_equal custom_client, strategy.client
    end

    test "initializes with default client when not provided" do
      image = images(:pending_image)
      strategy = BaseStrategy.new(image)

      assert_instance_of OcrApiClient, strategy.client
    end
  end
end
