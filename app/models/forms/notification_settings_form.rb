module Forms
  class NotificationSettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :enabled, :boolean
    attribute :subject, :string
    attribute :body, :string

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      return false unless valid?

      Setting.notification_email_enabled = enabled || false
      Setting.notification_email_subject = subject.presence || ""
      Setting.notification_email_body = body.presence || ""
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :notification_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "NotificationSettings")
    end

    private

    def load_from_settings
      self.enabled = Setting.notification_email_enabled
      self.subject = Setting.notification_email_subject.presence || Setting::DEFAULT_NOTIFICATION_SUBJECT
      self.body = Setting.notification_email_body.presence || Setting::DEFAULT_NOTIFICATION_BODY
    end
  end
end
