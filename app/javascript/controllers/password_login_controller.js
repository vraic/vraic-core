import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["passwordFields", "toggleSection"]

  showPassword() {
    this.passwordFieldsTargets.forEach((target) => target.classList.remove("hidden"))
    this.toggleSectionTarget.classList.add("hidden")
  }
}