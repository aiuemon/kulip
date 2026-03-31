import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nickname", "button", "result", "message"]

  async register() {
    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = "登録中..."
    this.hideResult()

    try {
      // 登録オプションを取得
      const optionsResponse = await fetch("/passkeys/registrations/new", {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      })

      if (!optionsResponse.ok) {
        const error = await optionsResponse.json()
        throw new Error(error.error || "登録オプションの取得に失敗しました")
      }

      const options = await optionsResponse.json()

      // WebAuthn API でクレデンシャルを作成
      const credential = await navigator.credentials.create({
        publicKey: {
          ...options,
          challenge: this.base64UrlToArrayBuffer(options.challenge),
          user: {
            ...options.user,
            id: this.base64UrlToArrayBuffer(options.user.id)
          },
          excludeCredentials: (options.excludeCredentials || []).map(cred => ({
            ...cred,
            id: this.base64UrlToArrayBuffer(cred.id)
          }))
        }
      })

      // クレデンシャルをサーバーに送信
      const createResponse = await fetch("/passkeys/registrations", {
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
              attestationObject: this.arrayBufferToBase64Url(credential.response.attestationObject),
              authenticatorAttachment: credential.authenticatorAttachment
            }
          },
          nickname: this.nicknameTarget.value.trim()
        })
      })

      const result = await createResponse.json()

      if (result.success) {
        this.showResult("パスキーを登録しました", "success")
        this.nicknameTarget.value = ""
        // ページをリロードして一覧を更新
        setTimeout(() => window.location.reload(), 1000)
      } else {
        throw new Error(result.error || "登録に失敗しました")
      }
    } catch (error) {
      if (error.name === "NotAllowedError") {
        this.showResult("登録がキャンセルされました", "warning")
      } else if (error.name === "InvalidStateError") {
        this.showResult("このパスキーは既に登録されています", "warning")
      } else {
        this.showResult(error.message, "danger")
      }
    } finally {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "パスキーを登録"
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
