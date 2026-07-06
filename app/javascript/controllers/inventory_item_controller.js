import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="inventory-item"
export default class extends Controller {
  static targets = ["unitType", "weightValue", "weightUnit"]

  connect() {
    this.updatePlaceholders()
  }

  updatePlaceholders() {
    const unitType = this.unitTypeTarget.value
    
    if (unitType === "per_weight") {
      this.weightValueTarget.placeholder = "e.g. 500"
      this.weightUnitTarget.placeholder = "e.g. g, kg, ml"
    } else {
      this.weightValueTarget.placeholder = "e.g. 1"
      this.weightUnitTarget.placeholder = "e.g. bag, pack, each"
    }
  }
}
