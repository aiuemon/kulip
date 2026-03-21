require "test_helper"

class SamlMetadataParserTest < ActiveSupport::TestCase
  VALID_METADATA = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
                      entityID="https://idp.example.com/metadata">
      <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <KeyDescriptor use="signing">
          <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <ds:X509Data>
              <ds:X509Certificate>MIICjDCCAXSgAwIBAgIGAY0test</ds:X509Certificate>
            </ds:X509Data>
          </ds:KeyInfo>
        </KeyDescriptor>
        <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
                             Location="https://idp.example.com/slo"/>
        <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
                             Location="https://idp.example.com/sso"/>
      </IDPSSODescriptor>
      <Organization>
        <OrganizationName xml:lang="en">Example IdP</OrganizationName>
        <OrganizationDisplayName xml:lang="en">Example Identity Provider</OrganizationDisplayName>
      </Organization>
    </EntityDescriptor>
  XML

  test "parse_xml は有効なメタデータを正しくパースする" do
    result = SamlMetadataParser.parse_xml(VALID_METADATA)

    assert result.success?
    assert_equal "https://idp.example.com/metadata", result.data[:entity_id]
    assert_equal "https://idp.example.com/sso", result.data[:idp_sso_url]
    assert_equal "https://idp.example.com/slo", result.data[:idp_slo_url]
    assert_includes result.data[:idp_cert], "BEGIN CERTIFICATE"
    assert_includes result.data[:idp_cert], "END CERTIFICATE"
    assert_equal "Example Identity Provider", result.data[:name]
  end

  test "parse_xml は空の XML でエラーを返す" do
    result = SamlMetadataParser.parse_xml("")

    assert_not result.success?
    assert_equal "XML が空です", result.error
  end

  test "parse_xml は nil でエラーを返す" do
    result = SamlMetadataParser.parse_xml(nil)

    assert_not result.success?
    assert_equal "XML が空です", result.error
  end

  test "parse_xml は EntityDescriptor がない XML でエラーを返す" do
    xml = "<root><child>test</child></root>"
    result = SamlMetadataParser.parse_xml(xml)

    assert_not result.success?
    assert_equal "EntityDescriptor が見つかりません", result.error
  end

  test "parse_xml は IDPSSODescriptor がない XML でエラーを返す" do
    xml = <<~XML
      <?xml version="1.0"?>
      <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" entityID="test">
      </EntityDescriptor>
    XML
    result = SamlMetadataParser.parse_xml(xml)

    assert_not result.success?
    assert_equal "IDPSSODescriptor が見つかりません", result.error
  end

  test "parse_xml は不正な XML でエラーを返す" do
    xml = "これは XML ではない"
    result = SamlMetadataParser.parse_xml(xml)

    # nokogiri は不正なXMLでもパースを試みるが、EntityDescriptor がないのでエラーになる
    assert_not result.success?
  end

  test "fetch_and_parse は空の URL でエラーを返す" do
    result = SamlMetadataParser.fetch_and_parse("")

    assert_not result.success?
    assert_equal "URL が空です", result.error
  end

  test "fetch_and_parse は無効な URL 形式でエラーを返す" do
    result = SamlMetadataParser.fetch_and_parse("not-a-url")

    assert_not result.success?
    assert_equal "無効な URL です", result.error
  end

  test "parse_xml は HTTP-POST バインディングの SSO URL も抽出する" do
    xml = <<~XML
      <?xml version="1.0"?>
      <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" entityID="test">
        <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
          <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
                               Location="https://idp.example.com/sso-post"/>
        </IDPSSODescriptor>
      </EntityDescriptor>
    XML

    result = SamlMetadataParser.parse_xml(xml)

    assert result.success?
    assert_equal "https://idp.example.com/sso-post", result.data[:idp_sso_url]
  end

  test "parse_xml は証明書を正しい PEM 形式にフォーマットする" do
    result = SamlMetadataParser.parse_xml(VALID_METADATA)

    assert result.success?
    cert = result.data[:idp_cert]
    assert_match(/\A-----BEGIN CERTIFICATE-----\n/, cert)
    assert_match(/\n-----END CERTIFICATE-----\z/, cert)
  end
end
