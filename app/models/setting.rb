class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  # === 定数 ===
  DEFAULT_OCR_TIMEOUT = 300

  DEFAULT_OCR_PROMPT = "この画像のテキストを文字起こししてください。単なる文字の羅列ではなく、見出し、段落、箇条書きなどをLLMの能力で解釈し、Markdown形式で美しく構造化して出力してください。\n推論プロセスは必ず <think> と </think> のタグで囲んで最初に出力し、その後に最終的なMarkdownテキストを出力してください。".freeze

  DEFAULT_OCR_OPTIONS = {
    "temperature" => 0.4,
    "num_predict" => -1,
    "num_ctx" => 33276,
    "num_keep" => 0,
    "repeat_penalty" => 1.2
  }.freeze

  DEFAULT_MAX_STORAGE_MB = 1024
  DEFAULT_AUTO_PURGE_DAYS = 7

  # === 認証設定 ===
  field :local_auth_enabled, type: :boolean, default: true
  field :local_auth_show_on_login, type: :boolean, default: true
  field :self_signup_enabled, type: :boolean, default: false

  # === OCR設定 ===
  field :ocr_endpoint, type: :string, default: ""
  field :ocr_api_key, type: :string, default: ""
  field :ocr_timeout, type: :integer, default: 300
  field :ocr_model, type: :string, default: ""
  field :ocr_prompt, type: :string, default: ""
  field :ocr_options, type: :hash, default: {}

  # === クォータ設定 ===
  field :max_storage_per_user_mb, type: :integer, default: 1024

  # === 保持設定 ===
  field :auto_purge_enabled, type: :boolean, default: false
  field :auto_purge_days, type: :integer, default: 7

  # === 互換性メソッド ===
  class << self
    # 認証設定
    def local_auth_enabled?
      local_auth_enabled
    end

    def local_auth_show_on_login?
      local_auth_show_on_login
    end

    def self_signup_enabled?
      self_signup_enabled
    end

    # OCR設定
    def ocr_configured?
      ocr_endpoint.present? && ocr_model.present?
    end

    def effective_ocr_timeout
      timeout = ocr_timeout
      timeout.present? && timeout > 0 ? timeout : DEFAULT_OCR_TIMEOUT
    end

    def effective_ocr_prompt
      ocr_prompt.presence || DEFAULT_OCR_PROMPT
    end

    def effective_ocr_options
      ocr_options.present? ? ocr_options : DEFAULT_OCR_OPTIONS
    end

    # クォータ設定
    def max_storage_mb
      mb = max_storage_per_user_mb
      mb.present? && mb > 0 ? mb : DEFAULT_MAX_STORAGE_MB
    end

    def max_storage_bytes
      max_storage_mb.megabytes
    end

    # 保持設定
    def auto_purge_enabled?
      auto_purge_enabled
    end

    def effective_auto_purge_days
      days = auto_purge_days
      days.present? && days > 0 ? days : DEFAULT_AUTO_PURGE_DAYS
    end
  end
end
