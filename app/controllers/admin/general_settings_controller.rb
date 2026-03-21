module Admin
  class GeneralSettingsController < BaseController
    def show
      @quota_setting = QuotaSetting.instance
    end

    def update
      @quota_setting = QuotaSetting.instance

      if @quota_setting.update(quota_setting_params)
        redirect_to admin_general_settings_path, notice: "一般設定を更新しました。"
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def quota_setting_params
      params.require(:quota_setting).permit(:max_storage_per_user_mb)
    end
  end
end
