import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "title", "link"]

  open(event) {
    event.preventDefault()

    const img = event.currentTarget
    const fullUrl = img.dataset.fullUrl
    const title = img.dataset.title || img.alt
    const imagePath = img.dataset.imagePath

    this.imageTarget.src = fullUrl
    this.imageTarget.alt = title
    this.titleTarget.textContent = title
    this.linkTarget.href = imagePath

    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close(event) {
    if (event) event.preventDefault()

    this.modalTarget.classList.add("hidden")
    this.imageTarget.src = ""
    document.body.style.overflow = ""
  }
}
