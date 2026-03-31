module Passkeys
  class CredentialsController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :ensure_passkey_enabled
    before_action :set_credential, only: %i[update destroy]

    # GET /passkeys/credentials
    # パスキー一覧・管理画面
    def index
      @credentials = current_user.webauthn_credentials.order(created_at: :desc)
    end

    # PATCH /passkeys/credentials/:id
    # パスキーの名前を変更
    def update
      if @credential.update(credential_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              dom_id(@credential),
              partial: "passkeys/credentials/credential",
              locals: { credential: @credential }
            )
          end
          format.html { redirect_to passkeys_credentials_path, notice: "パスキーの名前を変更しました" }
          format.json { render json: { success: true, credential: credential_json(@credential) } }
        end
      else
        respond_to do |format|
          format.html { redirect_to passkeys_credentials_path, alert: @credential.errors.full_messages.join(", ") }
          format.json { render json: { success: false, error: @credential.errors.full_messages.join(", ") }, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /passkeys/credentials/:id
    # パスキーを削除
    def destroy
      @credential.destroy!

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(dom_id(@credential))
        end
        format.html { redirect_to passkeys_credentials_path, notice: "パスキーを削除しました" }
        format.json { render json: { success: true } }
      end
    end

    private

    def ensure_passkey_enabled
      return if Setting.passkey_enabled?

      redirect_to root_path, alert: "パスキー機能は無効です"
    end

    def set_credential
      @credential = current_user.webauthn_credentials.find(params[:id])
    end

    def credential_params
      params.require(:webauthn_credential).permit(:nickname)
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
