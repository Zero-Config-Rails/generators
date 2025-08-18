import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  update(event) {
    const { target } = event
    const { dataset, checked } = target
    const configurationId = dataset.generatorCommandConfigurationIdValue
    const hideConfigurationName = dataset.generatorCommandHideConfigurationNameValue

    let value = target.value

    if (target.type === "checkbox") {
      value = checked
    }

    let updatedConfiguration = ` --${configurationId}=${value}`

    if (Boolean(hideConfigurationName)) {
      updatedConfiguration = ` ${value}`
    }

    const element = document.getElementById(configurationId)
    element.textContent = updatedConfiguration
    element.hidden = value === ""
  }
}
