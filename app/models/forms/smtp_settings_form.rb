module Forms
  class SmtpSettingsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    AUTHENTICATION_OPTIONS = %w[plain login cram_md5 none].freeze

    attribute :enabled, :boolean
    attribute :address, :string
    attribute :port, :integer
    attribute :authentication, :string
    attribute :user_name, :string
    attribute :password, :string
    attribute :enable_starttls, :boolean
    attribute :openssl_verify_none, :boolean
    attribute :from_address, :string

    validates :address, presence: true, if: :enabled
    validates :port, numericality: { only_integer: true, greater_than: 0, less_than: 65536 }, if: :enabled
    validates :authentication, inclusion: { in: AUTHENTICATION_OPTIONS }, allow_blank: true
    validates :from_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

    def initialize(attributes = {})
      super
      load_from_settings if attributes.empty?
    end

    def save
      return false unless valid?

      Setting.smtp_enabled = enabled || false
      Setting.smtp_address = address.presence || ""
      Setting.smtp_port = port.presence || 587
      Setting.smtp_authentication = authentication.presence || "plain"
      Setting.smtp_user_name = user_name.presence || ""
      Setting.smtp_password = password.presence || "" if password.present? || !enabled
      Setting.smtp_enable_starttls = enable_starttls.nil? ? true : enable_starttls
      Setting.smtp_openssl_verify_none = openssl_verify_none || false
      Setting.smtp_from_address = from_address.presence || ""
      true
    rescue => e
      errors.add(:base, e.message)
      false
    end

    def persisted?
      true
    end

    def to_key
      [ :smtp_settings ]
    end

    def model_name
      ActiveModel::Name.new(self, nil, "SmtpSettings")
    end

    def password_configured?
      Setting.smtp_password.present?
    end

    private

    def load_from_settings
      self.enabled = Setting.smtp_enabled
      self.address = Setting.smtp_address
      self.port = Setting.smtp_port.presence || 587
      self.authentication = Setting.smtp_authentication.presence || "plain"
      self.user_name = Setting.smtp_user_name
      self.enable_starttls = Setting.smtp_enable_starttls
      self.openssl_verify_none = Setting.smtp_openssl_verify_none
      self.from_address = Setting.smtp_from_address
    end
  end
end
