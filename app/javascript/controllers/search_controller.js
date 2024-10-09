import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  redirect(event) {
    const { target: { value: generator } } = event

    if (generator) {
      window.location.href = "/install/" + generator;
    }
  }
}
