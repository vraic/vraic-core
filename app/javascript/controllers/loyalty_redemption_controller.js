import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "customerSelect", "balanceDisplay", "redeemInput", "discountDisplay", "container" ]
  static values = { 
    customers: Object,
    ratio: Number 
  }

  connect() {
    this.updateBalance()
  }

  updateBalance() {
    if (!this.hasCustomerSelectTarget) return
    
    const customerId = this.customerSelectTarget.value
    const customer = this.customersValue[customerId]
    
    if (customer && customer.loyalty_card) {
      this.balanceDisplayTarget.textContent = `${customer.loyalty_card.points_balance} points available`
      this.redeemInputTarget.max = customer.loyalty_card.points_balance
      this.containerTarget.classList.remove("hidden")
    } else {
      this.balanceDisplayTarget.textContent = ""
      this.redeemInputTarget.value = 0
      this.containerTarget.classList.add("hidden")
    }
    this.updateDiscount()
  }

  updateDiscount() {
    const points = parseInt(this.redeemInputTarget.value) || 0
    const discount = (points * this.ratioValue).toFixed(2)
    this.discountDisplayTarget.textContent = `Discount: £${discount}`
  }
}
