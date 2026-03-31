require "test_helper"

class WebauthnCredentialTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @credential = webauthn_credentials(:one)
  end

  test "belongs to user" do
    assert_equal @user, @credential.user
  end

  test "validates presence of external_id" do
    credential = WebauthnCredential.new(user: @user, public_key: "test")
    assert_not credential.valid?
    assert credential.errors[:external_id].any?
  end

  test "validates uniqueness of external_id" do
    credential = WebauthnCredential.new(
      user: @user,
      external_id: @credential.external_id,
      public_key: "test"
    )
    assert_not credential.valid?
    assert credential.errors[:external_id].any?
  end

  test "validates presence of public_key" do
    credential = WebauthnCredential.new(user: @user, external_id: "unique-id")
    assert_not credential.valid?
    assert credential.errors[:public_key].any?
  end

  test "validates sign_count is not negative" do
    @credential.sign_count = -1
    assert_not @credential.valid?
  end

  test "validates authenticator_type inclusion" do
    @credential.authenticator_type = "invalid"
    assert_not @credential.valid?
    assert @credential.errors[:authenticator_type].any?
  end

  test "allows nil authenticator_type" do
    @credential.authenticator_type = nil
    assert @credential.valid?
  end

  test "update_sign_count! updates sign_count and last_used_at" do
    freeze_time do
      @credential.update_sign_count!(100)
      assert_equal 100, @credential.sign_count
      assert_equal Time.current, @credential.last_used_at
    end
  end

  test "display_name returns nickname if present" do
    assert_equal "MacBook Pro", @credential.display_name
  end

  test "display_name returns default name if nickname is blank" do
    @credential.nickname = nil
    assert_equal "パスキー #{@credential.id}", @credential.display_name
  end

  test "authenticator_type_name returns 組み込み認証器 for platform" do
    @credential.authenticator_type = "platform"
    assert_equal "組み込み認証器", @credential.authenticator_type_name
  end

  test "authenticator_type_name returns セキュリティキー for cross-platform" do
    @credential.authenticator_type = "cross-platform"
    assert_equal "セキュリティキー", @credential.authenticator_type_name
  end

  test "authenticator_type_name returns 不明 for nil" do
    @credential.authenticator_type = nil
    assert_equal "不明", @credential.authenticator_type_name
  end
end
