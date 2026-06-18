import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  update(event) {
    const { target } = event
    const configurationId = target.dataset.generatorCommandConfigurationIdValue
    const shouldHideConfigurationName = target.dataset.generatorCommandHideConfigurationNameValue === "true"
    const flagFormat = target.dataset.generatorCommandFlagFormatValue || "value"
    const negativePrefix = target.dataset.generatorCommandNegativePrefixValue || "skip"

    let value = target.type === "checkbox" ? target.checked : target.value
    let updatedConfiguration = ""
    let hidden = true

    if (shouldHideConfigurationName) {
      updatedConfiguration = value ? ` ${value}` : ""
      hidden = !value
    } else if (flagFormat === "positive_boolean") {
      if (value) updatedConfiguration = ` --${configurationId}`
      hidden = !value
    } else if (flagFormat === "negative_boolean") {
      if (!value) updatedConfiguration = ` --${negativePrefix}-${configurationId}`
      hidden = value
    } else {
      updatedConfiguration = value ? ` --${configurationId}=${value}` : ""
      hidden = !value
    }

    const element = document.getElementById(configurationId)
    if (!element) return

    element.textContent = updatedConfiguration
    element.hidden = hidden
  }
}
