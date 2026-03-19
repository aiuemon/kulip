require "test_helper"

class OcrSettingTest < ActiveSupport::TestCase
  setup do
    # テスト用にクリーンな状態にする
    OcrSetting.delete_all
  end

  test "instance creates singleton" do
    assert_difference "OcrSetting.count", 1 do
      OcrSetting.instance
    end

    # 2回目は作成しない
    assert_no_difference "OcrSetting.count" do
      OcrSetting.instance
    end
  end

  test "ocr_endpoint returns endpoint value" do
    setting = OcrSetting.instance
    setting.update!(endpoint: "http://example.com/api")
    assert_equal "http://example.com/api", OcrSetting.ocr_endpoint
  end

  test "ocr_endpoint returns nil when blank" do
    setting = OcrSetting.instance
    setting.update!(endpoint: "")
    assert_nil OcrSetting.ocr_endpoint
  end

  test "ocr_timeout returns default when not set" do
    setting = OcrSetting.instance
    setting.update!(timeout: nil)
    assert_equal OcrSetting::DEFAULT_TIMEOUT, OcrSetting.ocr_timeout
  end

  test "ocr_timeout returns custom value when set" do
    setting = OcrSetting.instance
    setting.update!(timeout: 600)
    assert_equal 600, OcrSetting.ocr_timeout
  end

  test "ocr_model returns model value" do
    setting = OcrSetting.instance
    setting.update!(model: "llava:latest")
    assert_equal "llava:latest", OcrSetting.ocr_model
  end

  test "ocr_prompt returns default when blank" do
    setting = OcrSetting.instance
    setting.update!(prompt: "")
    assert_equal OcrSetting::DEFAULT_PROMPT, OcrSetting.ocr_prompt
  end

  test "ocr_prompt returns custom value when set" do
    setting = OcrSetting.instance
    setting.update!(prompt: "Custom prompt")
    assert_equal "Custom prompt", OcrSetting.ocr_prompt
  end

  test "ocr_options returns default when blank" do
    setting = OcrSetting.instance
    setting.update!(options: nil)
    assert_equal OcrSetting::DEFAULT_OPTIONS, OcrSetting.ocr_options
  end

  test "configured? returns true when endpoint and model are set" do
    setting = OcrSetting.instance
    setting.update!(endpoint: "http://example.com", model: "llava")
    assert OcrSetting.configured?
  end

  test "configured? returns false when endpoint is blank" do
    setting = OcrSetting.instance
    setting.update!(endpoint: "", model: "llava")
    assert_not OcrSetting.configured?
  end

  test "configured? returns false when model is blank" do
    setting = OcrSetting.instance
    setting.update!(endpoint: "http://example.com", model: "")
    assert_not OcrSetting.configured?
  end
end
