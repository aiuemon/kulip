require "test_helper"

class QuotaSettingTest < ActiveSupport::TestCase
  setup do
    QuotaSetting.delete_all
  end

  test "instance creates singleton" do
    assert_difference "QuotaSetting.count", 1 do
      QuotaSetting.instance
    end

    assert_no_difference "QuotaSetting.count" do
      QuotaSetting.instance
    end
  end

  test "max_storage_mb returns default when not set" do
    setting = QuotaSetting.instance
    setting.update!(max_storage_per_user_mb: nil)
    assert_equal QuotaSetting::DEFAULT_MAX_STORAGE_MB, QuotaSetting.max_storage_mb
  end

  test "max_storage_mb returns default when set to zero" do
    setting = QuotaSetting.instance
    setting.update!(max_storage_per_user_mb: 0)
    assert_equal QuotaSetting::DEFAULT_MAX_STORAGE_MB, QuotaSetting.max_storage_mb
  end

  test "max_storage_mb returns configured value" do
    setting = QuotaSetting.instance
    setting.update!(max_storage_per_user_mb: 500)
    assert_equal 500, QuotaSetting.max_storage_mb
  end

  test "max_storage_bytes converts mb to bytes" do
    setting = QuotaSetting.instance
    setting.update!(max_storage_per_user_mb: 100)
    assert_equal 100.megabytes, QuotaSetting.max_storage_bytes
  end
end
