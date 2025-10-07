import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input"]

  connect() {
    this.element.addEventListener("subtask-form:hide", () => {
      this.hide()
    })
  }

  toggle() {
    this.formTarget.classList.toggle("hidden")
    
    if (!this.formTarget.classList.contains("hidden")) {
      this.inputTarget.focus()
    } else {
      this.inputTarget.value = ""
    }
  }

  cancel() {
    this.formTarget.classList.add("hidden")
    this.inputTarget.value = ""
  }

  hide() {
    this.formTarget.classList.add("hidden")
    this.inputTarget.value = ""
  }
}
