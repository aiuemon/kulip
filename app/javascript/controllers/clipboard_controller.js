import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { target: String }

  copy() {
    const targetElement = document.querySelector(this.targetValue)
    if (!targetElement) return

    const text = targetElement.value || targetElement.textContent

    navigator.clipboard.writeText(text).then(() => {
      const originalText = this.element.textContent
      this.element.textContent = "コピーしました"
      setTimeout(() => {
        this.element.textContent = originalText
      }, 2000)
    }).catch(() => {
      // フォールバック: 古いブラウザ向け
      targetElement.select()
      document.execCommand("copy")
    })
  }
}
