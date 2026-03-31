import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "result", "message"]

  async login() {
    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = "認証中..."
    this.hideResult()

    try {
      // 認証オプションを取得
      const optionsResponse = await fetch("/passkeys/sessions/new", {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      })

      if (!optionsResponse.ok) {
        const error = await optionsResponse.json()
        throw new Error(error.error || "認証オプションの取得に失敗しました")
      }

      const options = await optionsResponse.json()

      // WebAuthn API で認証
      const credential = await navigator.credentials.get({
        publicKey: {
          ...options,
          challenge: this.base64UrlToArrayBuffer(options.challenge),
          allowCredentials: (options.allowCredentials || []).map(cred => ({
            ...cred,
            id: this.base64UrlToArrayBuffer(cred.id)
          }))
        }
      })

      // 認証結果をサーバーに送信
      const authResponse = await fetch("/passkeys/sessions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({
          credential: {
            id: credential.id,
            rawId: this.arrayBufferToBase64Url(credential.rawId),
            type: credential.type,
            response: {
              clientDataJSON: this.arrayBufferToBase64Url(credential.response.clientDataJSON),
              authenticatorData: this.arrayBufferToBase64Url(credential.response.authenticatorData),
              signature: this.arrayBufferToBase64Url(credential.response.signature),
              userHandle: credential.response.userHandle ? this.arrayBufferToBase64Url(credential.response.userHandle) : null
            }
          }
        })
      })

      const result = await authResponse.json()

      if (result.success) {
        this.showResult("認証成功。リダイレクトします...", "success")
        window.location.href = result.redirect_url
      } else {
        throw new Error(result.error || "認証に失敗しました")
      }
    } catch (error) {
      if (error.name === "NotAllowedError") {
        this.showResult("認証がキャンセルされました", "warning")
      } else {
        this.showResult(error.message, "danger")
      }
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "パスキーでログイン"
    }
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  base64UrlToArrayBuffer(base64url) {
    const base64 = base64url.replace(/-/g, '+').replace(/_/g, '/')
    const padding = '='.repeat((4 - base64.length % 4) % 4)
    const binary = atob(base64 + padding)
    const bytes = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i)
    }
    return bytes.buffer
  }

  arrayBufferToBase64Url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ''
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')
  }

  showResult(message, type) {
    this.resultTarget.classList.remove("d-none")
    this.messageTarget.textContent = message
    this.messageTarget.className = `alert alert-${type} mb-0`
  }

  hideResult() {
    this.resultTarget.classList.add("d-none")
  }
}
