import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "button", "result", "message"]

  async send() {
    const email = this.emailTarget.value.trim()

    if (!email) {
      this.showResult("宛先メールアドレスを入力してください", "warning")
      return
    }

    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = "送信中..."

    try {
      const smtpSettings = this.collectSmtpSettings()
      const formData = new FormData()
      formData.append("to_address", email)

      Object.entries(smtpSettings).forEach(([key, value]) => {
        formData.append(`smtp_settings[${key}]`, value)
      })

      const response = await fetch("/admin/settings/send_test_email", {
        method: "POST",
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })

      const result = await response.json()

      if (result.success) {
        this.showResult(result.message, "success")
      } else {
        this.showResult(result.error, "danger")
      }
    } catch (error) {
      this.showResult("エラーが発生しました: " + error.message, "danger")
    } finally {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "テストメール送信"
    }
  }

  collectSmtpSettings() {
    const form = document.querySelector("#collapseSmtp form")
    if (!form) return {}

    return {
      address: form.querySelector('[name="smtp_settings[address]"]')?.value || "",
      port: form.querySelector('[name="smtp_settings[port]"]')?.value || "587",
      authentication: form.querySelector('[name="smtp_settings[authentication]"]')?.value || "plain",
      user_name: form.querySelector('[name="smtp_settings[user_name]"]')?.value || "",
      password: form.querySelector('[name="smtp_settings[password]"]')?.value || "",
      enable_starttls: form.querySelector('[name="smtp_settings[enable_starttls]"]')?.checked ? "true" : "false",
      from_address: form.querySelector('[name="smtp_settings[from_address]"]')?.value || ""
    }
  }

  showResult(message, type) {
    this.resultTarget.classList.remove("d-none")
    this.messageTarget.textContent = message
    this.messageTarget.className = `alert alert-${type} mb-0`
  }
}
