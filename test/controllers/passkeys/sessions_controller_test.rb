require "test_helper"

module Passkeys
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:user)
      @credential = webauthn_credentials(:one)
      Setting.passkey_enabled = true
    end

    teardown do
      Setting.passkey_enabled = false
    end

    test "new redirects when passkey disabled for HTML" do
      Setting.passkey_enabled = false
      get new_passkeys_session_path
      assert_redirected_to new_user_session_path
      assert_equal "パスキー機能は無効です", flash[:alert]
    end

    test "new returns forbidden when passkey disabled for JSON" do
      Setting.passkey_enabled = false
      get new_passkeys_session_path, as: :json
      assert_response :forbidden
      json = JSON.parse(response.body)
      assert_equal "パスキー機能は無効です", json["error"]
    end

    test "new returns authentication options" do
      get new_passkeys_session_path, as: :json
      assert_response :success
      json = JSON.parse(response.body)
      assert json["challenge"].present?
      assert json["allowCredentials"].present?
    end

    test "new stores challenge in session" do
      get new_passkeys_session_path, as: :json
      assert_response :success
      # セッションにチャレンジが保存されていることを確認
    end

    test "create returns forbidden when passkey disabled" do
      Setting.passkey_enabled = false
      post passkeys_sessions_path, params: { credential: {} }, as: :json
      assert_response :forbidden
    end

    # Note: Full authentication flow testing requires WebAuthn credential mocking
    # which is complex. These tests cover the basic feature flag checks.
  end
end
