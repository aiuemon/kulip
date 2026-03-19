// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Bootstrap dropdowns を Turbo ナビゲーション後に再初期化
document.addEventListener("turbo:load", () => {
  // Bootstrap が読み込まれている場合のみ実行
  if (typeof bootstrap !== "undefined") {
    document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach((element) => {
      new bootstrap.Dropdown(element)
    })
  }
})
