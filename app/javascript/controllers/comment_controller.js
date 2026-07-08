import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "form"]

  toggle() {
    this.bodyTarget.classList.toggle("hidden")
    this.formTarget.classList.toggle("hidden")
  }
}
