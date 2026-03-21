module Forms
  class RetentionSettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :auto_purge_enabled, :boolean
    attribute :auto_purge_days, :integer

    validates :auto_purge_days, numericality: { greater_than: 0 }, allow_blank: true

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      return false unless valid?

      Setting.auto_purge_enabled = auto_purge_enabled || false
      Setting.auto_purge_days = auto_purge_days.presence || Setting::DEFAULT_AUTO_PURGE_DAYS
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :retention_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "RetentionSettings")
    end

    private

    def load_from_settings
      self.auto_purge_enabled = Setting.auto_purge_enabled
      self.auto_purge_days = Setting.auto_purge_days
    end
  end
end
