module Forms
  class AuthSettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :local_auth_enabled, :boolean
    attribute :local_auth_show_on_login, :boolean
    attribute :self_signup_enabled, :boolean
    attribute :session_timeout_hours, :integer

    validates :session_timeout_hours, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      return false unless valid?

      Setting.local_auth_enabled = local_auth_enabled
      Setting.local_auth_show_on_login = local_auth_show_on_login
      Setting.self_signup_enabled = self_signup_enabled
      Setting.session_timeout_hours = session_timeout_hours.presence || 24
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :auth_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "AuthSettings")
    end

    private

    def load_from_settings
      self.local_auth_enabled = Setting.local_auth_enabled
      self.local_auth_show_on_login = Setting.local_auth_show_on_login
      self.self_signup_enabled = Setting.self_signup_enabled
      self.session_timeout_hours = Setting.session_timeout_hours.presence || 24
    end
  end
end
