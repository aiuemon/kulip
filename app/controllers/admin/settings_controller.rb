module Admin
  class SettingsController < BaseController
    def show
      @auth_form = Forms::AuthSettingsForm.new
      @ocr_form = Forms::OcrSettingsForm.new
      @quota_form = Forms::QuotaSettingsForm.new
    end

    def update_auth
      @auth_form = Forms::AuthSettingsForm.new(auth_settings_params)

      if @auth_form.save
        redirect_to admin_settings_path(anchor: "auth"), notice: "認証設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def update_ocr
      @ocr_form = Forms::OcrSettingsForm.new(ocr_settings_params)

      if @ocr_form.save
        redirect_to admin_settings_path(anchor: "ocr"), notice: "OCR設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def update_quota
      @quota_form = Forms::QuotaSettingsForm.new(quota_settings_params)

      if @quota_form.save
        redirect_to admin_settings_path(anchor: "quota"), notice: "クォータ設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    private

    def load_other_forms
      @auth_form ||= Forms::AuthSettingsForm.new
      @ocr_form ||= Forms::OcrSettingsForm.new
      @quota_form ||= Forms::QuotaSettingsForm.new
    end

    def auth_settings_params
      params.require(:auth_settings).permit(:local_auth_enabled, :local_auth_show_on_login, :self_signup_enabled)
    end

    def ocr_settings_params
      params.require(:ocr_settings).permit(:endpoint, :api_key, :timeout, :model, :prompt, :options)
    end

    def quota_settings_params
      params.require(:quota_settings).permit(:max_storage_per_user_mb)
    end
  end
end
