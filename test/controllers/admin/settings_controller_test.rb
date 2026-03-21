require "test_helper"

module Admin
  class SettingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
      Rails.cache.clear
    end

    test "requires authentication" do
      get admin_settings_path
      assert_redirected_to new_user_session_path
    end

    test "requires admin role" do
      sign_in @user
      get admin_settings_path
      assert_redirected_to root_path
      assert_equal "管理者権限が必要です。", flash[:alert]
    end

    test "show returns success for admin" do
      sign_in @admin
      get admin_settings_path
      assert_response :success
    end

    test "show displays all settings sections" do
      sign_in @admin
      get admin_settings_path
      assert_response :success
      assert_select "#auth"
      assert_select "#ocr"
      assert_select "#quota"
    end

    # Auth settings tests
    test "update_auth enables local auth" do
      sign_in @admin
      Setting.local_auth_enabled = false

      patch update_auth_admin_settings_path, params: {
        auth_settings: { local_auth_enabled: true }
      }

      assert_redirected_to admin_settings_path(anchor: "auth")
      assert Setting.local_auth_enabled?
    end

    test "update_auth changes self signup setting" do
      sign_in @admin
      Setting.self_signup_enabled = false

      patch update_auth_admin_settings_path, params: {
        auth_settings: { self_signup_enabled: true }
      }

      assert_redirected_to admin_settings_path(anchor: "auth")
      assert Setting.self_signup_enabled?
    end

    # OCR settings tests
    test "update_ocr changes endpoint" do
      sign_in @admin

      patch update_ocr_admin_settings_path, params: {
        ocr_settings: { endpoint: "http://new.example.com/api" }
      }

      assert_redirected_to admin_settings_path(anchor: "ocr")
      assert_equal "http://new.example.com/api", Setting.ocr_endpoint
    end

    test "update_ocr validates json options" do
      sign_in @admin

      patch update_ocr_admin_settings_path, params: {
        ocr_settings: { options: "invalid json" }
      }

      assert_response :unprocessable_entity
    end

    # Quota settings tests
    test "update_quota changes max storage" do
      sign_in @admin

      patch update_quota_admin_settings_path, params: {
        quota_settings: { max_storage_per_user_mb: 500 }
      }

      assert_redirected_to admin_settings_path(anchor: "quota")
      assert_equal 500, Setting.max_storage_per_user_mb
    end
  end
end
