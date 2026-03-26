# frozen_string_literal: true

module Forms
  class TimezoneSettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :timezone, :string

    validates :timezone, inclusion: { in: :valid_timezones, message: "は有効なタイムゾーンを選択してください" }

    # 主要なタイムゾーンのリスト（地名と UTC オフセット）
    TIMEZONE_OPTIONS = [
      [ "Asia/Tokyo (+09:00)", "Asia/Tokyo" ],
      [ "Asia/Seoul (+09:00)", "Asia/Seoul" ],
      [ "Asia/Shanghai (+08:00)", "Asia/Shanghai" ],
      [ "Asia/Hong_Kong (+08:00)", "Asia/Hong_Kong" ],
      [ "Asia/Singapore (+08:00)", "Asia/Singapore" ],
      [ "Asia/Bangkok (+07:00)", "Asia/Bangkok" ],
      [ "Asia/Jakarta (+07:00)", "Asia/Jakarta" ],
      [ "Asia/Kolkata (+05:30)", "Asia/Kolkata" ],
      [ "Asia/Dubai (+04:00)", "Asia/Dubai" ],
      [ "Europe/Moscow (+03:00)", "Europe/Moscow" ],
      [ "Europe/Istanbul (+03:00)", "Europe/Istanbul" ],
      [ "Europe/Berlin (+01:00)", "Europe/Berlin" ],
      [ "Europe/Paris (+01:00)", "Europe/Paris" ],
      [ "Europe/London (+00:00)", "Europe/London" ],
      [ "UTC (+00:00)", "UTC" ],
      [ "America/Sao_Paulo (-03:00)", "America/Sao_Paulo" ],
      [ "America/New_York (-05:00)", "America/New_York" ],
      [ "America/Chicago (-06:00)", "America/Chicago" ],
      [ "America/Denver (-07:00)", "America/Denver" ],
      [ "America/Los_Angeles (-08:00)", "America/Los_Angeles" ],
      [ "Pacific/Honolulu (-10:00)", "Pacific/Honolulu" ],
      [ "Pacific/Auckland (+12:00)", "Pacific/Auckland" ],
      [ "Australia/Sydney (+10:00)", "Australia/Sydney" ]
    ].freeze

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      return false unless valid?

      Setting.timezone = timezone.presence || Setting::DEFAULT_TIMEZONE
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :timezone_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "TimezoneSettings")
    end

    def self.timezone_options
      TIMEZONE_OPTIONS
    end

    private

    def load_from_settings
      self.timezone = Setting.timezone
    end

    def valid_timezones
      TIMEZONE_OPTIONS.map(&:last)
    end
  end
end
