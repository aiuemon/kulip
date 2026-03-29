import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: { type: String, default: "line" },
    labels: Array,
    data: Array,
    label: String,
    color: { type: String, default: "rgb(75, 192, 192)" }
  }

  connect() {
    this.initChart()
  }

  initChart() {
    if (typeof Chart === "undefined") {
      // Chart.js がまだ読み込まれていない場合は少し待ってリトライ
      setTimeout(() => this.initChart(), 100)
      return
    }

    this.chart = new Chart(this.element, {
      type: this.typeValue,
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: this.labelValue,
          data: this.dataValue,
          borderColor: this.colorValue,
          backgroundColor: this.colorValue.replace("rgb", "rgba").replace(")", ", 0.5)"),
          tension: 0.1,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { precision: 0 }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
}
