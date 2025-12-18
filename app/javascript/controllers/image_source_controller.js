import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["uploadTab", "urlTab", "uploadPanel", "urlPanel", "urlInput", "preview", "previewImage", "previewStatus"]

  connect() {
    if (this.hasUrlInputTarget) {
      this.urlInputTarget.addEventListener("input", this.debounce(this.previewUrl.bind(this), 500))
    }
  }

  showUpload() {
    this.uploadTabTarget.classList.add("active")
    this.urlTabTarget.classList.remove("active")
    this.uploadPanelTarget.classList.remove("hidden")
    this.urlPanelTarget.classList.add("hidden")
  }

  showUrl() {
    this.urlTabTarget.classList.add("active")
    this.uploadTabTarget.classList.remove("active")
    this.urlPanelTarget.classList.remove("hidden")
    this.uploadPanelTarget.classList.add("hidden")
  }

  previewUrl() {
    const url = this.urlInputTarget.value.trim()

    if (!url) {
      this.previewTarget.classList.add("hidden")
      return
    }

    if (!this.isValidUrl(url)) {
      this.showPreviewError("Please enter a valid URL")
      return
    }

    this.previewStatusTarget.textContent = "Loading preview..."
    this.previewTarget.classList.remove("hidden")
    this.previewImageTarget.classList.add("hidden")

    const img = new Image()
    img.onload = () => {
      this.previewImageTarget.src = url
      this.previewImageTarget.classList.remove("hidden")
      this.previewStatusTarget.textContent = "Image found - will be imported on save"
      this.previewStatusTarget.classList.remove("error")
      this.previewStatusTarget.classList.add("success")
    }
    img.onerror = () => {
      this.showPreviewError("Could not load image from URL")
    }
    img.src = url
  }

  showPreviewError(message) {
    this.previewTarget.classList.remove("hidden")
    this.previewImageTarget.classList.add("hidden")
    this.previewStatusTarget.textContent = message
    this.previewStatusTarget.classList.add("error")
    this.previewStatusTarget.classList.remove("success")
  }

  isValidUrl(string) {
    try {
      const url = new URL(string)
      return url.protocol === "http:" || url.protocol === "https:"
    } catch {
      return false
    }
  }

  debounce(func, wait) {
    let timeout
    return (...args) => {
      clearTimeout(timeout)
      timeout = setTimeout(() => func.apply(this, args), wait)
    }
  }
}
