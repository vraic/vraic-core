import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    // Auto-dismiss after 5 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.element.classList.add("opacity-0", "-translate-y-2", "sm:translate-x-2")
    
    // Wait for transition to finish before removing
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
