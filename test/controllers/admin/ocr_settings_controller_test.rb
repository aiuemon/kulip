require "test_helper"

module Admin
  class OcrSettingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
    end

    test "requires authentication" do
      get admin_ocr_settings_path
      assert_redirected_to new_user_session_path
    end

    test "requires admin role" do
      sign_in @user
      get admin_ocr_settings_path
      assert_redirected_to root_path
      assert_equal "管理者権限が必要です。", flash[:alert]
    end

    test "show returns success for admin" do
      sign_in @admin
      get admin_ocr_settings_path
      assert_response :success
    end

    test "update saves endpoint and model" do
      sign_in @admin

      patch admin_ocr_settings_path, params: {
        ocr_setting: {
          endpoint: "http://example.com/api",
          model: "llava:latest",
          options: ""
        }
      }

      assert_redirected_to admin_ocr_settings_path
      setting = OcrSetting.instance
      assert_equal "http://example.com/api", setting.endpoint
      assert_equal "llava:latest", setting.model
    end

    test "update saves timeout" do
      sign_in @admin

      patch admin_ocr_settings_path, params: {
        ocr_setting: {
          endpoint: "http://example.com/api",
          timeout: 600,
          options: ""
        }
      }

      assert_redirected_to admin_ocr_settings_path
      setting = OcrSetting.instance
      assert_equal 600, setting.timeout
    end

    test "update saves valid options JSON" do
      sign_in @admin

      patch admin_ocr_settings_path, params: {
        ocr_setting: {
          endpoint: "http://example.com/api",
          options: '{"temperature": 0.5}'
        }
      }

      assert_redirected_to admin_ocr_settings_path
      setting = OcrSetting.instance
      assert_equal({ "temperature" => 0.5 }, setting.options)
    end

    test "update fails with invalid JSON options" do
      sign_in @admin

      patch admin_ocr_settings_path, params: {
        ocr_setting: {
          endpoint: "http://example.com/api",
          options: "invalid json"
        }
      }

      assert_response :unprocessable_entity
      assert_equal "options の JSON 形式が不正です。", flash[:alert]
    end
  end
end
