require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "format_duration returns dash for nil" do
    assert_equal "-", format_duration(nil)
  end

  test "format_duration returns dash for zero" do
    assert_equal "-", format_duration(0)
  end

  test "format_duration formats seconds only" do
    assert_equal "5秒", format_duration(5)
    assert_equal "59秒", format_duration(59)
  end

  test "format_duration formats minutes and seconds" do
    assert_equal "1分00秒", format_duration(60)
    assert_equal "1分30秒", format_duration(90)
    assert_equal "59分59秒", format_duration(3599)
  end

  test "format_duration formats hours minutes and seconds" do
    assert_equal "1時間00分00秒", format_duration(3600)
    assert_equal "1時間30分45秒", format_duration(5445)
    assert_equal "2時間05分10秒", format_duration(7510)
  end
end
