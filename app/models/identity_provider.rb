class IdentityProvider < ApplicationRecord
  PROVIDER_TYPES = %w[saml oidc].freeze

  validates :provider_type, presence: true, inclusion: { in: PROVIDER_TYPES }
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_-]+\z/ }
  validates :settings, presence: true

  scope :enabled, -> { where(enabled: true) }
  scope :visible_on_login, -> { where(show_on_login: true) }
  scope :saml, -> { where(provider_type: "saml") }
  scope :oidc, -> { where(provider_type: "oidc") }

  before_validation :generate_slug, on: :create

  def saml?
    provider_type == "saml"
  end

  def oidc?
    provider_type == "oidc"
  end

  def omniauth_provider_name
    "#{provider_type}_#{slug}".to_sym
  end

  def omniauth_route_available?
    Devise.omniauth_configs.key?(omniauth_provider_name)
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = name.to_s.parameterize
    self.slug = base_slug

    counter = 1
    while IdentityProvider.exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
