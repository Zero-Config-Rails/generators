import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "checkbox"]

  copy() {
    const textToCopy = this.sourceTarget.innerText

    if (!this.checkboxTarget.checked && this.isManuallyTriggeredClick) {
      this.isManuallyTriggeredClick = false

      return
    }

    navigator.clipboard.writeText(textToCopy).then(
      () => {
        const x = this;

        setTimeout(function () {
          x.isManuallyTriggeredClick = true
          x.checkboxTarget.click()
        }, 1500)
      },
      () => {
        console.log("Failed to copy command to clipboard")
      },
    );
  }
}
