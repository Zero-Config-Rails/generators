import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  update(event) {
    const { target } = event
    const { dataset, checked } = target
    const configurationId = dataset.generatorCommandConfigurationIdValue

    let value = target.value

    if (target.type === "checkbox") {
      value = checked
    }

    const updatedConfiguration = ` --${configurationId}=${value}`

    document.getElementById(configurationId).textContent = updatedConfiguration
  }
}
