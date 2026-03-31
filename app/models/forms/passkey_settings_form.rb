module Forms
  class PasskeySettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :enabled, :boolean

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      Setting.passkey_enabled = enabled
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :passkey_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "PasskeySettings")
    end

    private

    def load_from_settings
      self.enabled = Setting.passkey_enabled
    end
  end
end
