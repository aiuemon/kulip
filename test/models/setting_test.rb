require "test_helper"

class SettingTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test "auth settings have correct defaults" do
    assert_equal true, Setting.local_auth_enabled
    assert_equal true, Setting.local_auth_show_on_login
    assert_equal false, Setting.self_signup_enabled
  end

  test "auth boolean methods work" do
    Setting.local_auth_enabled = false
    assert_not Setting.local_auth_enabled?

    Setting.local_auth_enabled = true
    assert Setting.local_auth_enabled?
  end

  test "ocr settings have correct defaults" do
    assert_equal "", Setting.ocr_endpoint
    assert_equal 300, Setting.ocr_timeout
  end

  test "ocr_configured? returns false without endpoint and model" do
    Setting.ocr_endpoint = ""
    Setting.ocr_model = ""
    assert_not Setting.ocr_configured?
  end

  test "ocr_configured? returns true with endpoint and model" do
    Setting.ocr_endpoint = "http://example.com/api"
    Setting.ocr_model = "llava:latest"
    assert Setting.ocr_configured?
  end

  test "effective_ocr_timeout returns default when not set" do
    Setting.ocr_timeout = 0
    assert_equal Setting::DEFAULT_OCR_TIMEOUT, Setting.effective_ocr_timeout
  end

  test "effective_ocr_prompt returns default when blank" do
    Setting.ocr_prompt = ""
    assert_equal Setting::DEFAULT_OCR_PROMPT, Setting.effective_ocr_prompt
  end

  test "effective_ocr_options returns default when empty" do
    Setting.ocr_options = {}
    assert_equal Setting::DEFAULT_OCR_OPTIONS, Setting.effective_ocr_options
  end

  test "quota settings have correct default" do
    assert_equal 1024, Setting.max_storage_per_user_mb
  end

  test "max_storage_bytes converts mb to bytes" do
    Setting.max_storage_per_user_mb = 100
    assert_equal 100.megabytes, Setting.max_storage_bytes
  end
end
