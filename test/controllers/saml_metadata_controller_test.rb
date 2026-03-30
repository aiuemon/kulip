require "test_helper"

class SamlMetadataControllerTest < ActionDispatch::IntegrationTest
  test "show returns XML metadata" do
    get saml_metadata_path
    assert_response :success
    assert_equal "application/xml; charset=utf-8", response.content_type
    assert_includes response.body, "EntityDescriptor"
  end

  test "show with download param returns attachment" do
    get saml_metadata_path(download: true)
    assert_response :success
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert_match(/saml_sp_metadata\.xml/, response.headers["Content-Disposition"])
  end

  test "metadata includes sp entity id" do
    get saml_metadata_path
    assert_response :success
    assert_includes response.body, "entityID="
  end

  test "metadata includes assertion consumer service" do
    get saml_metadata_path
    assert_response :success
    assert_includes response.body, "AssertionConsumerService"
  end
end
