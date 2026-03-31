module Passkeys
  class RegistrationsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: %i[create]
    before_action :ensure_passkey_enabled

    # GET /passkeys/registrations/new
    # パスキー登録オプションを取得（JSON）
    def new
      ensure_webauthn_id

      options = ::WebAuthn::Credential.options_for_create(
        user: {
          id: current_user.webauthn_id,
          name: current_user.email,
          display_name: current_user.email
        },
        exclude: current_user.webauthn_credentials.pluck(:external_id)
      )

      session[:webauthn_challenge] = options.challenge

      render json: options
    end

    # POST /passkeys/registrations
    # パスキーを登録
    def create
      webauthn_credential = ::WebAuthn::Credential.from_create(params[:credential])

      webauthn_credential.verify(session[:webauthn_challenge])

      credential = current_user.webauthn_credentials.create!(
        external_id: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count,
        authenticator_type: params.dig(:credential, :response, :authenticatorAttachment),
        nickname: params[:nickname].presence
      )

      session.delete(:webauthn_challenge)

      render json: { success: true, credential: credential_json(credential) }
    rescue ::WebAuthn::Error => e
      render json: { success: false, error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      render json: { success: false, error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end

    private

    def ensure_passkey_enabled
      return if Setting.passkey_enabled?

      respond_to do |format|
        format.html { redirect_to root_path, alert: "パスキー機能は無効です" }
        format.json { render json: { error: "パスキー機能は無効です" }, status: :forbidden }
      end
    end

    def ensure_webauthn_id
      return if current_user.webauthn_id.present?

      current_user.update!(webauthn_id: ::WebAuthn.generate_user_id)
    end

    def credential_json(credential)
      {
        id: credential.id,
        nickname: credential.display_name,
        authenticator_type: credential.authenticator_type_name,
        created_at: credential.created_at.iso8601,
        last_used_at: credential.last_used_at&.iso8601
      }
    end
  end
end
