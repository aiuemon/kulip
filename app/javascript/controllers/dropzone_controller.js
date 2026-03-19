import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label"]

  connect() {
    this.element.addEventListener("dragover", this.onDragOver.bind(this))
    this.element.addEventListener("dragleave", this.onDragLeave.bind(this))
    this.element.addEventListener("drop", this.onDrop.bind(this))
  }

  onDragOver(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.add("dropzone-active")
  }

  onDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.remove("dropzone-active")
  }

  onDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.element.classList.remove("dropzone-active")

    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.inputTarget.files = files
      this.updateLabel(files)
    }
  }

  onChange(event) {
    const files = event.target.files
    if (files.length > 0) {
      this.updateLabel(files)
    }
  }

  updateLabel(files) {
    if (this.hasLabelTarget) {
      if (files.length === 1) {
        this.labelTarget.textContent = files[0].name
      } else {
        this.labelTarget.textContent = `${files.length} 件のファイルが選択されました`
      }
    }
  }
}
