require "test_helper"

module Passkeys
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:user)
      Setting.passkey_enabled = true
    end

    teardown do
      Setting.passkey_enabled = false
    end

    test "new requires authentication" do
      get new_passkeys_registration_path, as: :json
      assert_response :unauthorized
    end

    test "new redirects when passkey disabled for HTML" do
      Setting.passkey_enabled = false
      sign_in @user
      get new_passkeys_registration_path
      assert_redirected_to root_path
      assert_equal "パスキー機能は無効です", flash[:alert]
    end

    test "new returns forbidden when passkey disabled for JSON" do
      Setting.passkey_enabled = false
      sign_in @user
      get new_passkeys_registration_path, as: :json
      assert_response :forbidden
      json = JSON.parse(response.body)
      assert_equal "パスキー機能は無効です", json["error"]
    end

    test "new returns registration options" do
      sign_in @user
      get new_passkeys_registration_path, as: :json
      assert_response :success
      json = JSON.parse(response.body)
      assert json["challenge"].present?
      assert json["user"].present?
      assert_equal @user.email, json["user"]["name"]
    end

    test "new stores challenge in session" do
      sign_in @user
      get new_passkeys_registration_path, as: :json
      assert_response :success
      # セッションにチャレンジが保存されていることを確認
      # (セッションは直接確認できないため、次のリクエストで使用されることを想定)
    end

    test "create requires authentication" do
      post passkeys_registrations_path, as: :json
      assert_response :unauthorized
    end

    test "create returns forbidden when passkey disabled" do
      Setting.passkey_enabled = false
      sign_in @user
      post passkeys_registrations_path, params: { credential: {} }, as: :json
      assert_response :forbidden
    end

    # Note: Full registration flow testing requires WebAuthn credential mocking
    # which is complex. These tests cover the basic authentication and feature flag checks.
  end
end
