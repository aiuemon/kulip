require "test_helper"

module Admin
  class IdentityProvidersControllerTest < ActionDispatch::IntegrationTest
    VALID_SAML_METADATA = <<~XML
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
          <OrganizationDisplayName xml:lang="en">Example IdP</OrganizationDisplayName>
        </Organization>
      </EntityDescriptor>
    XML

    setup do
      @admin = users(:admin)
      @user = users(:user)
    end

    test "parse_saml_metadata は認証が必要" do
      post parse_saml_metadata_admin_identity_providers_path
      assert_redirected_to new_user_session_path
    end

    test "parse_saml_metadata は管理者権限が必要" do
      sign_in @user
      post parse_saml_metadata_admin_identity_providers_path
      assert_redirected_to root_path
    end

    test "parse_saml_metadata はファイルアップロードで SAML メタデータをパースする" do
      sign_in @admin

      file = Rack::Test::UploadedFile.new(
        StringIO.new(VALID_SAML_METADATA),
        "application/xml",
        original_filename: "metadata.xml"
      )

      post parse_saml_metadata_admin_identity_providers_path, params: { metadata_file: file }

      assert_response :success
      json = JSON.parse(response.body)
      assert json["success"]
      assert_equal "https://idp.example.com/sso", json["data"]["idp_sso_url"]
      assert_equal "https://idp.example.com/slo", json["data"]["idp_slo_url"]
      assert_equal "https://idp.example.com/metadata", json["data"]["entity_id"]
      assert_equal "Example IdP", json["data"]["name"]
    end

    test "parse_saml_metadata はファイルも URL も指定されていない場合エラーを返す" do
      sign_in @admin

      post parse_saml_metadata_admin_identity_providers_path

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_not json["success"]
      assert_equal "メタデータファイルまたは URL を指定してください", json["error"]
    end

    test "parse_saml_metadata は無効な XML でエラーを返す" do
      sign_in @admin

      file = Rack::Test::UploadedFile.new(
        StringIO.new("<invalid>xml</invalid>"),
        "application/xml",
        original_filename: "invalid.xml"
      )

      post parse_saml_metadata_admin_identity_providers_path, params: { metadata_file: file }

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_not json["success"]
    end

    test "parse_saml_metadata は無効な URL でエラーを返す" do
      sign_in @admin

      post parse_saml_metadata_admin_identity_providers_path, params: { metadata_url: "not-a-url" }

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_not json["success"]
      assert_equal "無効な URL です", json["error"]
    end
  end
end
