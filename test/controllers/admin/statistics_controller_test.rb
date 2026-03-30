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

    test "show displays date selection form" do
      sign_in @admin
      get admin_statistics_path
      assert_response :success
      assert_select "input[type='date'][name='start_date']"
      assert_select "input[type='date'][name='end_date']"
      assert_select "input[type='submit'][value='表示']"
    end

    test "show with custom date range" do
      sign_in @admin
      start_date = 7.days.ago.to_date
      end_date = Date.current
      get admin_statistics_path, params: { start_date: start_date, end_date: end_date }
      assert_response :success
      assert_select "input[name='start_date'][value='#{start_date}']"
      assert_select "input[name='end_date'][value='#{end_date}']"
    end

    test "show with invalid date falls back to default" do
      sign_in @admin
      get admin_statistics_path, params: { start_date: "invalid", end_date: "invalid" }
      assert_response :success
      # デフォルト値が使われることを確認（エラーにならない）
      assert_select "input[name='start_date']"
      assert_select "input[name='end_date']"
    end
  end
end
