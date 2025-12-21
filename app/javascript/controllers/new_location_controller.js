import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "form", "name", "locationType", "city", "country", "error"]

  showForm(event) {
    event.preventDefault()
    this.formTarget.classList.remove("hidden")
  }

  hideForm(event) {
    if (event) event.preventDefault()
    this.formTarget.classList.add("hidden")
    this.clearForm()
  }

  clearForm() {
    this.nameTarget.value = ""
    this.locationTypeTarget.value = ""
    this.cityTarget.value = ""
    this.countryTarget.value = ""
    this.errorTarget.classList.add("hidden")
    this.errorTarget.textContent = ""
  }

  async create(event) {
    event.preventDefault()

    const name = this.nameTarget.value.trim()
    if (!name) {
      this.showError("Name is required")
      return
    }

    const data = {
      location: {
        name: name,
        location_type: this.locationTypeTarget.value,
        city: this.cityTarget.value.trim(),
        country: this.countryTarget.value.trim()
      }
    }

    try {
      const response = await fetch("/locations", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify(data)
      })

      if (response.ok) {
        const location = await response.json()
        this.addLocationToSelect(location)
        this.hideForm()
      } else {
        const errors = await response.json()
        this.showError(errors.errors ? errors.errors.join(", ") : "Failed to create location")
      }
    } catch (error) {
      this.showError("An error occurred. Please try again.")
    }
  }

  addLocationToSelect(location) {
    const select = this.selectTarget
    const option = document.createElement("option")
    option.value = location.id
    option.textContent = location.name
    option.selected = true

    // Insert in alphabetical order
    const options = Array.from(select.options)
    let inserted = false
    for (let i = 1; i < options.length; i++) { // Start at 1 to skip blank option
      if (options[i].textContent.toLowerCase() > location.name.toLowerCase()) {
        select.insertBefore(option, options[i])
        inserted = true
        break
      }
    }
    if (!inserted) {
      select.appendChild(option)
    }
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }
}
