require "test_helper"

module Admin
  class StatisticsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
    end

    test "requires authentication" do
      get admin_statistics_path
      assert_redirected_to new_user_session_path
    end

    test "requires admin role" do
      sign_in @user
      get admin_statistics_path
      assert_redirected_to root_path
      assert_equal "管理者権限が必要です。", flash[:alert]
    end

    test "show returns success for admin" do
      sign_in @admin
      get admin_statistics_path
      assert_response :success
    end

    test "show displays statistics sections" do
      sign_in @admin
      get admin_statistics_path
      assert_response :success
      assert_select "h1", "統計情報"
      assert_select ".card", minimum: 3
    end

    test "show displays summary cards" do
      sign_in @admin
      get admin_statistics_path
      assert_response :success
      assert_select ".card-title", /利用者数/
      assert_select ".card-title", /アップロード数/
      assert_select ".card-title", /処理時間/
    end

    test "show displays chart canvases" do
      sign_in @admin
      get admin_statistics_path
      assert_response :success
      assert_select "canvas[data-controller='chart']", 3
    end
  end
end
