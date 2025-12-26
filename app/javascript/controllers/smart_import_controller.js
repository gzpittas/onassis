import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step1", "step2",
    "urlInput", "preview", "previewImage",
    "analyzeBtn", "loading", "error", "errorMessage",
    "form", "remoteUrl",
    "title", "notes", "takenDate", "datePrecision", "location",
    "charactersGrid", "locationsGrid",
    "suggestedCharacters", "suggestedCharactersList",
    "suggestedLocations", "suggestedLocationsList",
    "confidence", "confidenceText"
  ]

  connect() {
    // Preview image when URL is pasted
    this.urlInputTarget.addEventListener("input", this.updatePreview.bind(this))
    this.urlInputTarget.addEventListener("paste", () => {
      setTimeout(() => this.updatePreview(), 0)
    })
  }

  updatePreview() {
    const url = this.urlInputTarget.value.trim()
    if (url && this.isValidUrl(url)) {
      this.previewImageTarget.src = url
      this.previewTarget.classList.remove("hidden")
    } else {
      this.previewTarget.classList.add("hidden")
    }
  }

  isValidUrl(string) {
    try {
      new URL(string)
      return true
    } catch (_) {
      return false
    }
  }

  async analyze() {
    const url = this.urlInputTarget.value.trim()

    if (!url) {
      this.showError("Please enter an image URL")
      return
    }

    if (!this.isValidUrl(url)) {
      this.showError("Please enter a valid URL")
      return
    }

    this.hideError()
    this.showLoading()

    try {
      const response = await fetch("/smart_import/analyze", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ url: url })
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Analysis failed")
      }

      this.populateForm(url, data.analysis)
      this.showStep2()

    } catch (error) {
      this.showError(error.message)
    } finally {
      this.hideLoading()
    }
  }

  populateForm(url, analysis) {
    // Set the remote URL for import
    this.remoteUrlTarget.value = url

    // Populate text fields
    this.titleTarget.value = analysis.title || ""
    this.notesTarget.value = analysis.description || ""
    this.locationTarget.value = analysis.location || ""

    // Handle date
    if (analysis.taken_date) {
      this.takenDateTarget.value = analysis.taken_date
    }
    if (analysis.taken_date_precision) {
      this.datePrecisionTarget.value = analysis.taken_date_precision
    }

    // Check matched characters
    this.uncheckAll(this.charactersGridTarget)
    if (analysis.matched_character_ids) {
      analysis.matched_character_ids.forEach(id => {
        const checkbox = this.charactersGridTarget.querySelector(`[data-character-id="${id}"] input`)
        if (checkbox) checkbox.checked = true
      })
    }

    // Check matched locations
    this.uncheckAll(this.locationsGridTarget)
    if (analysis.matched_location_ids) {
      analysis.matched_location_ids.forEach(id => {
        const checkbox = this.locationsGridTarget.querySelector(`[data-location-id="${id}"] input`)
        if (checkbox) checkbox.checked = true
      })
    }

    // Show suggested new characters
    if (analysis.suggested_new_characters && analysis.suggested_new_characters.length > 0) {
      this.suggestedCharactersListTarget.innerHTML = analysis.suggested_new_characters
        .map(name => `<li>${name}</li>`)
        .join("")
      this.suggestedCharactersTarget.classList.remove("hidden")
    } else {
      this.suggestedCharactersTarget.classList.add("hidden")
    }

    // Show suggested new locations
    if (analysis.suggested_new_locations && analysis.suggested_new_locations.length > 0) {
      this.suggestedLocationsListTarget.innerHTML = analysis.suggested_new_locations
        .map(name => `<li>${name}</li>`)
        .join("")
      this.suggestedLocationsTarget.classList.remove("hidden")
    } else {
      this.suggestedLocationsTarget.classList.add("hidden")
    }

    // Show confidence notes
    if (analysis.confidence_notes) {
      this.confidenceTextTarget.textContent = analysis.confidence_notes
      this.confidenceTarget.classList.remove("hidden")
    } else {
      this.confidenceTarget.classList.add("hidden")
    }
  }

  uncheckAll(container) {
    container.querySelectorAll('input[type="checkbox"]').forEach(cb => cb.checked = false)
  }

  showStep2() {
    this.step1Target.classList.add("hidden")
    this.step2Target.classList.remove("hidden")
  }

  back() {
    this.step2Target.classList.add("hidden")
    this.step1Target.classList.remove("hidden")
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
    this.analyzeBtnTarget.disabled = true
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden")
    this.analyzeBtnTarget.disabled = false
  }

  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorTarget.classList.remove("hidden")
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }
}
