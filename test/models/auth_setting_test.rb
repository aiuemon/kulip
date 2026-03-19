require "test_helper"

class AuthSettingTest < ActiveSupport::TestCase
  setup do
    # テスト用にクリーンな状態にする
    AuthSetting.delete_all
  end

  test "instance creates singleton" do
    assert_difference "AuthSetting.count", 1 do
      AuthSetting.instance
    end

    # 2回目は作成しない
    assert_no_difference "AuthSetting.count" do
      AuthSetting.instance
    end
  end

  test "local_auth_enabled? returns setting value" do
    setting = AuthSetting.instance
    setting.update!(local_auth_enabled: true)
    assert AuthSetting.local_auth_enabled?

    setting.update!(local_auth_enabled: false)
    assert_not AuthSetting.local_auth_enabled?
  end

  test "local_auth_show_on_login? returns setting value" do
    setting = AuthSetting.instance
    setting.update!(local_auth_show_on_login: true)
    assert AuthSetting.local_auth_show_on_login?

    setting.update!(local_auth_show_on_login: false)
    assert_not AuthSetting.local_auth_show_on_login?
  end

  test "self_signup_enabled? returns setting value" do
    setting = AuthSetting.instance
    setting.update!(self_signup_enabled: true)
    assert AuthSetting.self_signup_enabled?

    setting.update!(self_signup_enabled: false)
    assert_not AuthSetting.self_signup_enabled?
  end
end
