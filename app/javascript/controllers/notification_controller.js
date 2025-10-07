import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: Number }

  connect() {
    this.timeoutValue = this.timeoutValue || 3000
    this.hide()
  }

  hide() {
    setTimeout(() => {
      this.element.style.opacity = "0"
      this.element.style.transform = "translateX(100%)"
      
      setTimeout(() => {
        if (this.element.parentNode) {
          this.element.remove()
        }
      }, 300)
    }, this.timeoutValue)
  }
}
