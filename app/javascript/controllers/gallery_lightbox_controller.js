import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "title", "link", "item", "counter"]

  connect() {
    this.currentIndex = 0
    this.boundKeyHandler = this.handleKeydown.bind(this)
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const imageId = button.dataset.imageId

    // Build array of currently visible images
    this.images = this.itemTargets.map(item => ({
      id: item.dataset.imageId,
      fullUrl: item.dataset.fullUrl,
      title: item.dataset.title,
      path: item.dataset.path
    }))

    // Find the index of the clicked image
    this.currentIndex = this.images.findIndex(img => img.id === imageId)
    if (this.currentIndex === -1) this.currentIndex = 0

    this.showCurrentImage()
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    document.addEventListener("keydown", this.boundKeyHandler)
  }

  close(event) {
    if (event) event.preventDefault()

    this.modalTarget.classList.add("hidden")
    this.imageTarget.src = ""
    document.body.style.overflow = ""
    document.removeEventListener("keydown", this.boundKeyHandler)
  }

  next(event) {
    if (event) event.preventDefault()
    if (this.images.length === 0) return

    this.currentIndex = (this.currentIndex + 1) % this.images.length
    this.showCurrentImage()
  }

  previous(event) {
    if (event) event.preventDefault()
    if (this.images.length === 0) return

    this.currentIndex = (this.currentIndex - 1 + this.images.length) % this.images.length
    this.showCurrentImage()
  }

  showCurrentImage() {
    const image = this.images[this.currentIndex]
    if (!image) return

    this.imageTarget.src = image.fullUrl
    this.imageTarget.alt = image.title
    this.titleTarget.textContent = image.title
    this.linkTarget.href = image.path

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.currentIndex + 1} / ${this.images.length}`
    }
  }

  handleKeydown(event) {
    switch (event.key) {
      case "Escape":
        this.close()
        break
      case "ArrowRight":
        this.next()
        break
      case "ArrowLeft":
        this.previous()
        break
    }
  }
}
