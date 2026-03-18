class Admin::OcrSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def show
    @ocr_setting = OcrSetting.instance
  end

  def update
    @ocr_setting = OcrSetting.instance

    # options を JSON としてパース
    options_param = params[:ocr_setting][:options]
    parsed_options = parse_options(options_param)

    if parsed_options.nil? && options_param.present?
      flash.now[:alert] = "options の JSON 形式が不正です。"
      render :show, status: :unprocessable_entity
      return
    end

    if @ocr_setting.update(
      endpoint: params[:ocr_setting][:endpoint],
      api_key: params[:ocr_setting][:api_key],
      timeout: params[:ocr_setting][:timeout],
      model: params[:ocr_setting][:model],
      prompt: params[:ocr_setting][:prompt],
      options: parsed_options || {}
    )
      redirect_to admin_ocr_settings_path, notice: "OCR 設定を更新しました。"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: "管理者権限が必要です。"
    end
  end

  def parse_options(options_str)
    return {} if options_str.blank?
    JSON.parse(options_str)
  rescue JSON::ParserError
    nil
  end
end
