module Passkeys
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :ensure_passkey_enabled

    # GET /passkeys/sessions/new
    # パスキー認証オプションを取得（JSON）
    def new
      options = ::WebAuthn::Credential.options_for_get(
        allow: ::WebauthnCredential.pluck(:external_id)
      )

      session[:webauthn_challenge] = options.challenge

      render json: options
    end

    # POST /passkeys/sessions
    # パスキーで認証してログイン
    def create
      webauthn_credential = ::WebAuthn::Credential.from_get(params[:credential])

      stored_credential = ::WebauthnCredential.find_by!(external_id: webauthn_credential.id)

      webauthn_credential.verify(
        session[:webauthn_challenge],
        public_key: stored_credential.public_key,
        sign_count: stored_credential.sign_count
      )

      stored_credential.update_sign_count!(webauthn_credential.sign_count)

      session.delete(:webauthn_challenge)

      # Devise でログイン
      sign_in(stored_credential.user)

      render json: { success: true, redirect_url: root_path }
    rescue ::WebAuthn::Error => e
      render json: { success: false, error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: { success: false, error: "パスキーが見つかりません" }, status: :unprocessable_entity
    end

    private

    def ensure_passkey_enabled
      return if Setting.passkey_enabled?

      respond_to do |format|
        format.html { redirect_to new_user_session_path, alert: "パスキー機能は無効です" }
        format.json { render json: { error: "パスキー機能は無効です" }, status: :forbidden }
      end
    end
  end
end
