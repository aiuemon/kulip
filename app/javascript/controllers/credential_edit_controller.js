import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["displayName", "editForm", "actions", "input"]

  edit() {
    this.displayNameTarget.classList.add("d-none")
    this.actionsTarget.classList.add("d-none")
    this.editFormTarget.classList.remove("d-none")
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  cancel() {
    this.editFormTarget.classList.add("d-none")
    this.displayNameTarget.classList.remove("d-none")
    this.actionsTarget.classList.remove("d-none")
  }

  save(event) {
    // Turbo Streams が処理を行うため、フォーム送信は通常通り
    // 成功時にパーシャルが再描画される
  }
}
