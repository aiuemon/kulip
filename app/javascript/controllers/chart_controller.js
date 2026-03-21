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
    // Chart.js is loaded via script tag in the view
    if (typeof Chart === "undefined") {
      console.error("Chart.js is not loaded")
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
