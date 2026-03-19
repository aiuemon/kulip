require "test_helper"

module Admin
  class AuthSettingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
    end

    test "requires authentication" do
      get admin_auth_settings_path
      assert_redirected_to new_user_session_path
    end

    test "requires admin role" do
      sign_in @user
      get admin_auth_settings_path
      assert_redirected_to root_path
      assert_equal "管理者権限が必要です。", flash[:alert]
    end

    test "show returns success for admin" do
      sign_in @admin
      get admin_auth_settings_path
      assert_response :success
    end

    test "update enables local auth" do
      sign_in @admin
      setting = AuthSetting.instance
      setting.update!(local_auth_enabled: false)

      patch admin_auth_settings_path, params: {
        auth_setting: { local_auth_enabled: true }
      }

      assert_redirected_to admin_auth_settings_path
      setting.reload
      assert setting.local_auth_enabled?
    end

    test "update changes self signup setting" do
      sign_in @admin
      setting = AuthSetting.instance
      setting.update!(self_signup_enabled: false)

      patch admin_auth_settings_path, params: {
        auth_setting: { self_signup_enabled: true }
      }

      assert_redirected_to admin_auth_settings_path
      setting.reload
      assert setting.self_signup_enabled?
    end
  end
end
