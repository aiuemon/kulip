class OcrCompletionMailer < ApplicationMailer
  def completion_notification(image)
    @image = image
    @user = image.user

    return unless @user.email.present?

    subject = render_template(Setting.effective_notification_subject)
    @body = render_template(Setting.effective_notification_body)

    mail(
      to: @user.email,
      subject: subject
    )
  end

  private

  def render_template(template)
    template
      .gsub("{{user_name}}", user_display_name)
      .gsub("{{image_name}}", @image.name)
      .gsub("{{ocr_duration}}", format_duration(@image.ocr_duration))
      .gsub("{{image_url}}", image_url(@image))
  end

  def user_display_name
    @user.name.presence || @user.email.split("@").first
  end

  def format_duration(duration)
    return "不明" if duration.blank?

    duration.round(1).to_s
  end
end
