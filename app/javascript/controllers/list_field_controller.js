import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "row"]
  static values = { outputId: String, format: String }

  connect() {
    this.rowTargets.forEach((row) => this.updateRowVisibility(row))
    this.refresh()
  }

  add() {
    const newRow = this.rowTargets[0].cloneNode(true)
    this.resetRow(newRow)
    this.containerTarget.appendChild(newRow)
    this.updateRowVisibility(newRow)
    this.refresh()
  }

  remove(event) {
    if (this.rowTargets.length <= 1) return

    event.target.closest("[data-list-field-target='row']")?.remove()
    this.refresh()
  }

  typeChanged(event) {
    const row = event.target.closest("[data-list-field-target='row']")
    if (!row) return

    this.updateRowVisibility(row)
    this.refresh()
  }

  refresh() {
    const parts = this.rowTargets.map((row) => this.formatRow(row)).filter(Boolean)
    const element = document.getElementById(this.outputIdValue)
    if (!element) return

    const text = parts.length ? ` ${parts.join(" ")}` : ""
    element.textContent = text
    element.hidden = !text
  }

  formatRow(row) {
    const values = {}
    row.querySelectorAll("[data-list-field-key]").forEach((el) => {
      const key = el.dataset.listFieldKey
      if (el.type === "checkbox") {
        values[key] = el.checked
      } else {
        values[key] = el.value.trim()
      }
    })

    switch (this.formatValue) {
      case "rails_attribute": {
        if (!values.name) return null

        const type = values.type || "string"
        let part = `${values.name}:${type}`

        const modifier = this.railsAttributeModifier(values)
        if (modifier) part += `{${modifier}}`
        if (values.index) part += `:${values.index}`

        return part
      }
      case "space_separated":
        return values.name || null
      default:
        return null
    }
  }

  railsAttributeModifier(values) {
    if (values.type === "references" && values.polymorphic) return "polymorphic"
    if (values.limit) return values.limit

    return null
  }

  updateRowVisibility(row) {
    const type = row.querySelector('[data-list-field-key="type"]')?.value || "string"

    row.querySelectorAll("[data-list-field-cell]").forEach((cell) => {
      const types = cell.dataset.listFieldShowForTypes
      if (!types) return

      cell.classList.toggle("hidden", !JSON.parse(types).includes(type))
    })

    const limitInput = row.querySelector('[data-list-field-key="limit"]')
    if (limitInput?.dataset.listFieldPlaceholders) {
      const placeholders = JSON.parse(limitInput.dataset.listFieldPlaceholders)
      limitInput.placeholder = placeholders[type] || placeholders.default || "30"
    }
  }

  resetRow(row) {
    row.querySelectorAll("input").forEach((input) => {
      if (input.type === "checkbox") {
        input.checked = false
      } else {
        input.value = ""
      }
    })
    row.querySelectorAll("select").forEach((select) => {
      select.selectedIndex = 0
    })
    this.updateRowVisibility(row)
  }
}
