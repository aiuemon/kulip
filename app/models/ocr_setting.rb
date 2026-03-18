class OcrSetting < ApplicationRecord
  DEFAULT_TIMEOUT = 300

  DEFAULT_PROMPT = "この画像のテキストを文字起こししてください。単なる文字の羅列ではなく、見出し、段落、箇条書きなどをLLMの能力で解釈し、Markdown形式で美しく構造化して出力してください。\n推論プロセスは必ず <think> と </think> のタグで囲んで最初に出力し、その後に最終的なMarkdownテキストを出力してください。".freeze

  DEFAULT_OPTIONS = {
    "temperature" => 0.4,
    "num_predict" => -1,
    "num_ctx" => 33276,
    "num_keep" => 0,
    "repeat_penalty" => 1.2
  }.freeze

  # シングルトンインスタンスを取得
  def self.instance
    first_or_create!
  end

  # 設定値を取得するクラスメソッド
  def self.ocr_endpoint
    instance.endpoint.presence
  end

  def self.ocr_api_key
    instance.api_key.presence
  end

  def self.ocr_timeout
    timeout = instance.timeout
    timeout.present? && timeout > 0 ? timeout : DEFAULT_TIMEOUT
  end

  def self.ocr_model
    instance.model.presence
  end

  def self.ocr_prompt
    instance.prompt.presence || DEFAULT_PROMPT
  end

  def self.ocr_options
    opts = instance.options
    opts.present? ? opts : DEFAULT_OPTIONS
  end

  # API設定が有効かどうか
  def self.configured?
    ocr_endpoint.present? && ocr_model.present?
  end
end
