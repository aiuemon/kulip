module Admin
  class AuthSettingsController < BaseController
    def show
      @auth_setting = AuthSetting.instance
    end

    def update
      @auth_setting = AuthSetting.instance

      if @auth_setting.update(auth_setting_params)
        redirect_to admin_auth_settings_path, notice: "認証設定を更新しました。"
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def auth_setting_params
      params.require(:auth_setting).permit(:local_auth_enabled, :local_auth_show_on_login, :self_signup_enabled)
    end
  end
end
