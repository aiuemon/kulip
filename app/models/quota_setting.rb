class QuotaSetting < ApplicationRecord
  DEFAULT_MAX_STORAGE_MB = 1024 # 1GB

  # シングルトンインスタンスを取得
  def self.instance
    first_or_create!
  end

  # 最大ストレージ容量（MB）
  def self.max_storage_mb
    mb = instance.max_storage_per_user_mb
    mb.present? && mb > 0 ? mb : DEFAULT_MAX_STORAGE_MB
  end

  # 最大ストレージ容量（バイト）
  def self.max_storage_bytes
    max_storage_mb.megabytes
  end
end
