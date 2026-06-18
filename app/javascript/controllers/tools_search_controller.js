import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item", "section", "empty"]

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()

    this.itemTargets.forEach((item) => {
      const haystack = item.dataset.toolsSearchTextValue.toLowerCase()
      item.classList.toggle("hidden", query.length > 0 && !haystack.includes(query))
    })

    this.sectionTargets.forEach((section) => {
      const visibleItems = section.querySelectorAll("[data-tools-search-target='item']:not(.hidden)")
      section.classList.toggle("hidden", query.length > 0 && visibleItems.length === 0)
    })

    if (this.hasEmptyTarget) {
      const anyVisible = this.itemTargets.some((item) => !item.classList.contains("hidden"))
      this.emptyTarget.classList.toggle("hidden", query.length === 0 || anyVisible)
    }
  }

  clear() {
    this.inputTarget.value = ""
    this.filter()
  }
}
