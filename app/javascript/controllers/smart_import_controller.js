import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step1", "step2",
    "urlInput", "pageUrlInput", "preview", "previewImage",
    "imagesSection", "imageGrid",
    "analyzeBtn", "loading", "error", "errorMessage",
    "form", "remoteUrl",
    "title", "notes", "takenDate", "datePrecision", "location",
    "charactersGrid", "locationsGrid", "assetsGrid",
    "suggestedCharacters", "suggestedCharactersList",
    "suggestedLocations", "suggestedLocationsList",
    "confidence", "confidenceText"
  ]

  connect() {
    this.selectedImageUrl = null

    // Fetch images when page URL is entered
    if (this.hasPageUrlInputTarget) {
      this.pageUrlInputTarget.addEventListener("blur", this.fetchImagesFromPage.bind(this))
      this.pageUrlInputTarget.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
          e.preventDefault()
          this.fetchImagesFromPage()
        }
      })
    }

    // Preview when direct URL is pasted
    if (this.hasUrlInputTarget) {
      this.urlInputTarget.addEventListener("input", this.updatePreviewFromDirectUrl.bind(this))
      this.urlInputTarget.addEventListener("paste", () => {
        setTimeout(() => this.updatePreviewFromDirectUrl(), 0)
      })
    }
  }

  async fetchImagesFromPage() {
    const pageUrl = this.pageUrlInputTarget.value.trim()
    if (!pageUrl || !this.isValidUrl(pageUrl)) return

    this.hideError()
    this.showLoading()

    try {
      const response = await fetch("/smart_import/fetch_images", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ page_url: pageUrl })
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Failed to fetch images")
      }

      this.displayImageOptions(data.images)

    } catch (error) {
      this.showError(error.message)
    } finally {
      this.hideLoading()
    }
  }

  displayImageOptions(images) {
    if (!images || images.length === 0) {
      this.showError("No suitable images found on this page")
      return
    }

    this.imageGridTarget.innerHTML = ""

    images.forEach((image, index) => {
      const div = document.createElement("div")
      div.className = "smart-import-image-option"
      div.dataset.imageUrl = image.url
      div.innerHTML = `
        <img src="${image.url}" alt="${image.alt || 'Image ' + (index + 1)}" loading="lazy">
        ${image.caption ? `<p class="image-option-caption">${image.caption.substring(0, 50)}${image.caption.length > 50 ? '...' : ''}</p>` : ''}
      `
      div.addEventListener("click", () => this.selectImage(image.url, div))
      this.imageGridTarget.appendChild(div)
    })

    this.imagesSectionTarget.classList.remove("hidden")
  }

  selectImage(url, element) {
    // Remove selection from all
    this.imageGridTarget.querySelectorAll(".smart-import-image-option").forEach(el => {
      el.classList.remove("selected")
    })

    // Select this one
    element.classList.add("selected")
    this.selectedImageUrl = url

    // Show preview
    this.previewImageTarget.src = url
    this.previewTarget.classList.remove("hidden")

    // Clear direct URL input since we're using the page selection
    if (this.hasUrlInputTarget) {
      this.urlInputTarget.value = ""
    }
  }

  updatePreviewFromDirectUrl() {
    const url = this.urlInputTarget.value.trim()
    if (url && this.isValidUrl(url)) {
      this.previewImageTarget.src = url
      this.previewTarget.classList.remove("hidden")
      this.selectedImageUrl = url

      // Clear image grid selection
      if (this.hasImageGridTarget) {
        this.imageGridTarget.querySelectorAll(".smart-import-image-option").forEach(el => {
          el.classList.remove("selected")
        })
      }
    } else {
      this.previewTarget.classList.add("hidden")
      this.selectedImageUrl = null
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
    const imageUrl = this.selectedImageUrl || (this.hasUrlInputTarget ? this.urlInputTarget.value.trim() : "")
    const pageUrl = this.hasPageUrlInputTarget ? this.pageUrlInputTarget.value.trim() : ""

    if (!imageUrl) {
      this.showError("Please select an image or enter an image URL")
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
        body: JSON.stringify({ url: imageUrl, page_url: pageUrl })
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Analysis failed")
      }

      this.populateForm(imageUrl, data.analysis)
      this.showStep2()

    } catch (error) {
      this.showError(error.message)
    } finally {
      this.hideLoading()
    }
  }

  populateForm(url, analysis) {
    // Set the remote URL for import (use Getty preview URL if available)
    this.remoteUrlTarget.value = analysis.image_url || url

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

    // Check matched assets
    if (this.hasAssetsGridTarget) {
      this.uncheckAll(this.assetsGridTarget)
      if (analysis.matched_asset_ids) {
        analysis.matched_asset_ids.forEach(id => {
          const checkbox = this.assetsGridTarget.querySelector(`[data-asset-id="${id}"] input`)
          if (checkbox) checkbox.checked = true
        })
      }
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
