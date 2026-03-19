require "test_helper"

class IdentityProviderTest < ActiveSupport::TestCase
  test "valid provider types" do
    assert_equal %w[saml oidc], IdentityProvider::PROVIDER_TYPES
  end

  test "saml? returns true for saml provider" do
    idp = identity_providers(:saml_idp)
    assert idp.saml?
    assert_not idp.oidc?
  end

  test "oidc? returns true for oidc provider" do
    idp = identity_providers(:oidc_idp)
    assert idp.oidc?
    assert_not idp.saml?
  end

  test "enabled scope returns only enabled providers" do
    enabled = IdentityProvider.enabled
    enabled.each do |idp|
      assert idp.enabled?
    end
  end

  test "visible_on_login scope returns only visible providers" do
    visible = IdentityProvider.visible_on_login
    visible.each do |idp|
      assert idp.show_on_login?
    end
  end

  test "validates presence of provider_type" do
    idp = IdentityProvider.new(name: "Test", slug: "test", settings: { foo: "bar" })
    assert_not idp.valid?
    assert_includes idp.errors[:provider_type], "can't be blank"
  end

  test "validates provider_type inclusion" do
    idp = IdentityProvider.new(
      name: "Test",
      slug: "test",
      provider_type: "invalid",
      settings: { foo: "bar" }
    )
    assert_not idp.valid?
    assert_includes idp.errors[:provider_type], "is not included in the list"
  end

  test "validates presence of name" do
    idp = IdentityProvider.new(provider_type: "saml", slug: "test", settings: { foo: "bar" })
    assert_not idp.valid?
    assert_includes idp.errors[:name], "can't be blank"
  end

  test "validates slug format" do
    idp = IdentityProvider.new(
      name: "Test",
      slug: "Invalid Slug!",
      provider_type: "saml",
      settings: { foo: "bar" }
    )
    assert_not idp.valid?
    assert_includes idp.errors[:slug], "is invalid"
  end

  test "validates slug uniqueness" do
    existing = identity_providers(:saml_idp)
    idp = IdentityProvider.new(
      name: "Test",
      slug: existing.slug,
      provider_type: "saml",
      settings: { foo: "bar" }
    )
    assert_not idp.valid?
    assert_includes idp.errors[:slug], "has already been taken"
  end

  test "omniauth_provider_name returns correct format" do
    idp = identity_providers(:saml_idp)
    assert_equal :"saml_#{idp.slug}", idp.omniauth_provider_name
  end

  test "generates slug from name on create" do
    idp = IdentityProvider.new(
      name: "My Test Provider",
      provider_type: "saml",
      settings: { foo: "bar" }
    )
    idp.valid?
    assert_equal "my-test-provider", idp.slug
  end
end
