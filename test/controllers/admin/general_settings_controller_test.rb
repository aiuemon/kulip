require "test_helper"

module Admin
  class GeneralSettingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
    end

    test "requires authentication" do
      get admin_general_settings_path
      assert_redirected_to new_user_session_path
    end

    test "requires admin role" do
      sign_in @user
      get admin_general_settings_path
      assert_redirected_to root_path
      assert_equal "管理者権限が必要です。", flash[:alert]
    end

    test "show returns success for admin" do
      sign_in @admin
      get admin_general_settings_path
      assert_response :success
    end

    test "show displays current quota setting" do
      sign_in @admin
      QuotaSetting.instance.update!(max_storage_per_user_mb: 2048)

      get admin_general_settings_path
      assert_response :success
      assert_select "input[value='2048']"
    end

    test "update changes quota setting" do
      sign_in @admin
      setting = QuotaSetting.instance
      setting.update!(max_storage_per_user_mb: 1024)

      patch admin_general_settings_path, params: {
        quota_setting: { max_storage_per_user_mb: 500 }
      }

      assert_redirected_to admin_general_settings_path
      setting.reload
      assert_equal 500, setting.max_storage_per_user_mb
    end
  end
end
