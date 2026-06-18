import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open() {
    this.element.setAttribute("open", "")
  }

  close(event) {
    if (event?.target && this.element.contains(event.target)) return

    this.element.removeAttribute("open")
  }
}
