import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static values = {
    data: Array,
    label: String,
    type: { type: String, default: 'line' }
  }

  connect() {
    this.renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  renderChart() {
    const ctx = this.element.getContext('2d')
    const labels = this.dataValue.map(item => item.label)
    const values = this.dataValue.map(item => item.value)

    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: {
        labels: labels,
        datasets: [{
          label: this.labelValue,
          data: values,
          backgroundColor: 'rgba(79, 70, 229, 0.2)',
          borderColor: 'rgb(79, 70, 229)',
          borderWidth: 2,
          fill: this.typeValue === 'line',
          tension: 0.1
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
            beginAtZero: true
          }
        }
      }
    })
  }
}
