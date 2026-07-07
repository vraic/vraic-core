import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["itemSelect", "locationSelect", "quantityInput", "priceInput", "priceDisplay"]

  connect() {
    this.updateStockLimit()
  }

  // Triggered by itemSelect change
  updateItem() {
    this.updatePrice()
    this.updateStockLimit()
  }

  // Triggered by locationSelect change
  updateLocation() {
    this.updateStockLimit()
  }

  updatePrice() {
    const selectedOption = this.itemSelectTarget.selectedOptions[0]
    if (!selectedOption || !selectedOption.value) return

    const stockData = JSON.parse(selectedOption.dataset.stockData || "{}")
    if (stockData.price !== undefined) {
      const price = stockData.price.toFixed(2)
      
      if (this.hasPriceInputTarget) {
        this.priceInputTarget.value = price
      }
      
      if (this.hasPriceDisplayTarget) {
        this.priceDisplayTarget.textContent = price
      }
    }
  }

  updateStockLimit() {
    const selectedOption = this.itemSelectTarget.selectedOptions[0]
    if (!selectedOption || !selectedOption.value) {
      this.quantityInputTarget.removeAttribute("max")
      return
    }

    const stockData = JSON.parse(selectedOption.dataset.stockData || "{}")
    const locationId = this.hasLocationSelectTarget ? this.locationSelectTarget.value : null

    let maxStock = 0
    if (locationId && stockData.locations && stockData.locations[locationId] !== undefined) {
      maxStock = stockData.locations[locationId]
    } else {
      // If no location selected (staff) or no location field (customer)
      // Use total stock as the limit
      maxStock = stockData.total || 0
    }

    this.quantityInputTarget.setAttribute("max", maxStock)
  }
}
