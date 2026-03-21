import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["file", "fileButton", "url", "status", "statusMessage"]

  fileSelected() {
    const hasFile = this.fileTarget.files.length > 0
    this.fileButtonTarget.disabled = !hasFile
  }

  async uploadFile() {
    const file = this.fileTarget.files[0]
    if (!file) return

    this.showStatus("読み込み中...", "info")

    const formData = new FormData()
    formData.append("metadata_file", file)

    await this.sendRequest(formData)
  }

  async fetchUrl() {
    const url = this.urlTarget.value.trim()
    if (!url) {
      this.showStatus("URL を入力してください", "warning")
      return
    }

    this.showStatus("取得中...", "info")

    const formData = new FormData()
    formData.append("metadata_url", url)

    await this.sendRequest(formData)
  }

  async sendRequest(formData) {
    try {
      const response = await fetch("/admin/identity_providers/parse_saml_metadata", {
        method: "POST",
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })

      const result = await response.json()

      if (result.success) {
        this.fillForm(result.data)
        this.showStatus("メタデータを読み込みました", "success")
      } else {
        this.showStatus(result.error, "danger")
      }
    } catch (error) {
      this.showStatus("エラーが発生しました: " + error.message, "danger")
    }
  }

  fillForm(data) {
    if (data.name) {
      const nameField = document.getElementById("identity_provider_name")
      if (nameField && !nameField.value) {
        nameField.value = data.name
      }
    }

    if (data.idp_sso_url) {
      const ssoField = document.getElementById("settings_idp_sso_url")
      if (ssoField) ssoField.value = data.idp_sso_url
    }

    if (data.idp_slo_url) {
      const sloField = document.getElementById("settings_idp_slo_url")
      if (sloField) sloField.value = data.idp_slo_url
    }

    if (data.idp_cert) {
      const certField = document.getElementById("settings_idp_cert")
      if (certField) certField.value = data.idp_cert
    }

    if (data.entity_id) {
      const entityIdField = document.getElementById("settings_sp_entity_id")
      // SP entity ID はそのまま使うかどうか判断が必要なので、参考情報としてログに出力
      console.log("IdP Entity ID:", data.entity_id)
    }
  }

  showStatus(message, type) {
    this.statusTarget.classList.remove("d-none")
    this.statusMessageTarget.textContent = message
    this.statusMessageTarget.className = `alert alert-${type} mb-0 py-2`
  }
}
