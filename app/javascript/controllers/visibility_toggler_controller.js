import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  change(event) {
    const { checked } = event.target

    if (checked) {
      this.containerTarget.classList.remove('hidden')
    } else {
      this.containerTarget.classList.add('hidden')
    }
  }
}
