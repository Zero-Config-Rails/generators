import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  change(event) {
    const { checked } = event.target

    if (checked) {
      this.containerTarget.classList.remove("hidden")
    } else {
      this.containerTarget.classList.add("hidden")
    }
  }

  hide() {
    if (!this.hasContainerTarget) return
    if (this.containerTarget.classList.contains("hidden")) return

    const checkbox = this.element.querySelector('input[type="checkbox"]')
    if (checkbox) checkbox.checked = false

    this.containerTarget.classList.add("hidden")
  }
}
