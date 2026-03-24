class TestMailer < ApplicationMailer
  def test_email(to:, smtp_settings: {})
    @sent_at = Time.current

    # 動的に SMTP 設定を適用
    if smtp_settings.present?
      mail.delivery_method.settings.merge!(smtp_settings)
    end

    mail(
      to: to,
      subject: "[kulip] SMTP 設定テストメール",
      from: smtp_settings[:from_address].presence || Setting.smtp_from_address.presence || "noreply@example.com"
    )
  end
end
