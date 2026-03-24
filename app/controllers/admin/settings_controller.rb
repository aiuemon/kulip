module Admin
  class SettingsController < BaseController
    def show
      @auth_form = Forms::AuthSettingsForm.new
      @ocr_form = Forms::OcrSettingsForm.new
      @quota_form = Forms::QuotaSettingsForm.new
      @retention_form = Forms::RetentionSettingsForm.new
      @notification_form = Forms::NotificationSettingsForm.new
      @smtp_form = Forms::SmtpSettingsForm.new
    end

    def update_auth
      @auth_form = Forms::AuthSettingsForm.new(auth_settings_params)

      if @auth_form.save
        redirect_to admin_settings_path(anchor: "collapseAuth"), notice: "認証設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def update_ocr
      @ocr_form = Forms::OcrSettingsForm.new(ocr_settings_params)

      if @ocr_form.save
        redirect_to admin_settings_path(anchor: "collapseOcr"), notice: "OCR設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def update_quota
      @quota_form = Forms::QuotaSettingsForm.new(quota_settings_params)

      if @quota_form.save
        redirect_to admin_settings_path(anchor: "collapseUserFiles"), notice: "クォータ設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def update_retention
      @retention_form = Forms::RetentionSettingsForm.new(retention_settings_params)

      if @retention_form.save
        redirect_to admin_settings_path(anchor: "collapseUserFiles"), notice: "保持設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def update_notification
      @notification_form = Forms::NotificationSettingsForm.new(notification_settings_params)

      if @notification_form.save
        redirect_to admin_settings_path(anchor: "collapseNotification"), notice: "通知メール設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def update_smtp
      @smtp_form = Forms::SmtpSettingsForm.new(smtp_settings_params)

      if @smtp_form.save
        redirect_to admin_settings_path(anchor: "collapseSmtp"), notice: "送信メールサーバ設定を更新しました。"
      else
        load_other_forms
        render :show, status: :unprocessable_entity
      end
    end

    def send_test_email
      to_address = params[:to_address]

      if to_address.blank?
        render json: { success: false, error: "宛先メールアドレスを入力してください" }, status: :unprocessable_entity
        return
      end

      smtp_settings = build_smtp_settings_from_params

      begin
        TestMailer.test_email(to: to_address, smtp_settings: smtp_settings).deliver_now
        render json: { success: true, message: "テストメールを送信しました" }
      rescue => e
        render json: { success: false, error: "送信に失敗しました: #{e.message}" }, status: :unprocessable_entity
      end
    end

    private

    def build_smtp_settings_from_params
      smtp_params = params[:smtp_settings] || {}

      settings = {
        address: smtp_params[:address].presence,
        port: smtp_params[:port].to_i,
        enable_starttls_auto: smtp_params[:enable_starttls] == "true" || smtp_params[:enable_starttls] == "1",
        from_address: smtp_params[:from_address].presence
      }

      auth = smtp_params[:authentication].presence
      if auth.present? && auth != "none"
        settings[:authentication] = auth.to_sym
        settings[:user_name] = smtp_params[:user_name].presence
        # パスワードが入力されていればそれを使用、なければ保存済みのパスワードを使用
        settings[:password] = smtp_params[:password].presence || Setting.smtp_password.presence
      end

      settings.compact
    end

    def load_other_forms
      @auth_form ||= Forms::AuthSettingsForm.new
      @ocr_form ||= Forms::OcrSettingsForm.new
      @quota_form ||= Forms::QuotaSettingsForm.new
      @retention_form ||= Forms::RetentionSettingsForm.new
      @notification_form ||= Forms::NotificationSettingsForm.new
      @smtp_form ||= Forms::SmtpSettingsForm.new
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

    def retention_settings_params
      params.require(:retention_settings).permit(:auto_purge_enabled, :auto_purge_days)
    end

    def notification_settings_params
      params.require(:notification_settings).permit(:enabled, :subject, :body)
    end

    def smtp_settings_params
      params.require(:smtp_settings).permit(
        :enabled, :address, :port, :authentication,
        :user_name, :password, :enable_starttls, :from_address
      )
    end
  end
end
