class SamlMetadataController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    settings = saml_settings
    meta = OneLogin::RubySaml::Metadata.new
    xml = meta.generate(settings, true)

    if params[:download].present?
      send_data xml, filename: "saml_sp_metadata.xml", type: "application/xml", disposition: "attachment"
    else
      render xml: xml
    end
  end

  private

  def saml_settings
    settings = OneLogin::RubySaml::Settings.new

    # SP 設定
    settings.sp_entity_id = sp_entity_id
    settings.assertion_consumer_service_url = assertion_consumer_service_url
    settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    settings
  end

  def sp_entity_id
    Setting.effective_saml_sp_entity_id(request.base_url)
  end

  def assertion_consumer_service_url
    # OmniAuth SAML の ACS URL パターン
    # 複数の IdP がある場合は汎用的なパターンを表示
    saml_idp = IdentityProvider.where(provider_type: "saml").first
    if saml_idp
      "#{request.base_url}/users/auth/saml_#{saml_idp.slug}/callback"
    else
      "#{request.base_url}/users/auth/saml_{slug}/callback"
    end
  end
end
