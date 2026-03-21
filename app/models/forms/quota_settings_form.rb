module Forms
  class QuotaSettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :max_storage_per_user_mb, :integer

    validates :max_storage_per_user_mb, numericality: { greater_than: 0 }, allow_blank: true

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      return false unless valid?

      Setting.max_storage_per_user_mb = max_storage_per_user_mb.presence || Setting::DEFAULT_MAX_STORAGE_MB
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :quota_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "QuotaSettings")
    end

    private

    def load_from_settings
      self.max_storage_per_user_mb = Setting.max_storage_per_user_mb
    end
  end
end
