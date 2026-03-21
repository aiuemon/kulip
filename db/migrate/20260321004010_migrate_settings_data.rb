class MigrateSettingsData < ActiveRecord::Migration[8.1]
  def up
    # AuthSetting からデータを移行
    if table_exists?(:auth_settings)
      auth = execute("SELECT * FROM auth_settings LIMIT 1").first
      if auth
        insert_setting("local_auth_enabled", auth["local_auth_enabled"])
        insert_setting("local_auth_show_on_login", auth["local_auth_show_on_login"])
        insert_setting("self_signup_enabled", auth["self_signup_enabled"])
      end
    end

    # OcrSetting からデータを移行
    if table_exists?(:ocr_settings)
      ocr = execute("SELECT * FROM ocr_settings LIMIT 1").first
      if ocr
        insert_setting("ocr_endpoint", ocr["endpoint"]) if ocr["endpoint"].present?
        insert_setting("ocr_api_key", ocr["api_key"]) if ocr["api_key"].present?
        insert_setting("ocr_timeout", ocr["timeout"]) if ocr["timeout"].present?
        insert_setting("ocr_model", ocr["model"]) if ocr["model"].present?
        insert_setting("ocr_prompt", ocr["prompt"]) if ocr["prompt"].present?
        insert_setting("ocr_options", ocr["options"]) if ocr["options"].present?
      end
    end

    # QuotaSetting からデータを移行
    if table_exists?(:quota_settings)
      quota = execute("SELECT * FROM quota_settings LIMIT 1").first
      if quota && quota["max_storage_per_user_mb"].present?
        insert_setting("max_storage_per_user_mb", quota["max_storage_per_user_mb"])
      end
    end
  end

  def down
    # 設定データを削除（元テーブルにはロールバックしない）
    execute("DELETE FROM settings WHERE var IN ('local_auth_enabled', 'local_auth_show_on_login', 'self_signup_enabled', 'ocr_endpoint', 'ocr_api_key', 'ocr_timeout', 'ocr_model', 'ocr_prompt', 'ocr_options', 'max_storage_per_user_mb')")
  end

  private

  def insert_setting(var, value)
    return if value.nil?

    now = Time.current.to_fs(:db)
    escaped_value = value.is_a?(String) ? value.gsub("'", "''") : value.to_s
    execute("INSERT INTO settings (var, value, created_at, updated_at) VALUES ('#{var}', '#{escaped_value}', '#{now}', '#{now}')")
  end
end
