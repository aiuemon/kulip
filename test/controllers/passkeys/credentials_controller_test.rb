require "test_helper"

module Passkeys
  class CredentialsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:user)
      @other_user = users(:admin)
      @credential = webauthn_credentials(:one)
      Setting.passkey_enabled = true
    end

    teardown do
      Setting.passkey_enabled = false
    end

    test "index requires authentication" do
      get passkeys_credentials_path
      assert_redirected_to new_user_session_path
    end

    test "index redirects when passkey disabled" do
      Setting.passkey_enabled = false
      sign_in @user
      get passkeys_credentials_path
      assert_redirected_to root_path
      assert_equal "パスキー機能は無効です", flash[:alert]
    end

    test "index displays credentials list" do
      sign_in @user
      get passkeys_credentials_path
      assert_response :success
      assert_select "h1", "パスキー管理"
      assert_select "#credentials-list li", count: 2
    end

    test "update changes credential nickname" do
      sign_in @user
      patch passkeys_credential_path(@credential), params: {
        webauthn_credential: { nickname: "New Name" }
      }
      assert_redirected_to passkeys_credentials_path
      assert_equal "New Name", @credential.reload.nickname
    end

    test "update with turbo_stream" do
      sign_in @user
      patch passkeys_credential_path(@credential), params: {
        webauthn_credential: { nickname: "New Name" }
      }, as: :turbo_stream
      assert_response :success
      assert_equal "New Name", @credential.reload.nickname
    end

    test "update with json" do
      sign_in @user
      patch passkeys_credential_path(@credential), params: {
        webauthn_credential: { nickname: "New Name" }
      }, as: :json
      assert_response :success
      json = JSON.parse(response.body)
      assert json["success"]
      assert_equal "New Name", json["credential"]["nickname"]
    end

    test "update rejects other user's credential" do
      sign_in @other_user
      patch passkeys_credential_path(@credential), params: {
        webauthn_credential: { nickname: "Hacked" }
      }
      assert_response :not_found
    end

    test "destroy deletes credential" do
      sign_in @user
      assert_difference("WebauthnCredential.count", -1) do
        delete passkeys_credential_path(@credential)
      end
      assert_redirected_to passkeys_credentials_path
    end

    test "destroy with turbo_stream" do
      sign_in @user
      assert_difference("WebauthnCredential.count", -1) do
        delete passkeys_credential_path(@credential), as: :turbo_stream
      end
      assert_response :success
    end

    test "destroy with json" do
      sign_in @user
      assert_difference("WebauthnCredential.count", -1) do
        delete passkeys_credential_path(@credential), as: :json
      end
      assert_response :success
      json = JSON.parse(response.body)
      assert json["success"]
    end

    test "destroy rejects other user's credential" do
      sign_in @other_user
      delete passkeys_credential_path(@credential)
      assert_response :not_found
    end
  end
end
