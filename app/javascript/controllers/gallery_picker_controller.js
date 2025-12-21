import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "item", "preview", "hiddenInputs", "lightbox", "lightboxImage", "lightboxTitle", "featuredInput"]
  static values = { featured: String }

  connect() {
    this.selectedImages = new Map()
    this.featuredImageId = this.hasFeaturedValue ? this.featuredValue : null

    // Initialize from existing selections
    this.itemTargets.forEach(item => {
      if (item.dataset.selected === "true") {
        const id = item.dataset.imageId
        this.selectedImages.set(id, {
          id: id,
          title: item.dataset.imageTitle,
          url: item.dataset.imageUrl,
          fullUrl: item.dataset.imageFullUrl
        })
        item.classList.add("selected")
      }
    })
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  toggleImage(event) {
    const item = event.currentTarget
    const id = item.dataset.imageId

    if (this.selectedImages.has(id)) {
      this.selectedImages.delete(id)
      item.classList.remove("selected")
    } else {
      this.selectedImages.set(id, {
        id: id,
        title: item.dataset.imageTitle,
        url: item.dataset.imageUrl,
        fullUrl: item.dataset.imageFullUrl
      })
      item.classList.add("selected")
    }
  }

  showLightbox(event) {
    event.preventDefault()
    event.stopPropagation()

    const img = event.currentTarget
    const fullUrl = img.dataset.fullUrl
    const title = img.dataset.title || img.alt

    if (fullUrl && this.hasLightboxTarget) {
      this.lightboxImageTarget.src = fullUrl
      this.lightboxImageTarget.alt = title
      this.lightboxTitleTarget.textContent = title
      this.lightboxTarget.classList.remove("hidden")
      document.body.style.overflow = "hidden"
    }
  }

  closeLightbox(event) {
    if (event) event.preventDefault()
    if (this.hasLightboxTarget) {
      this.lightboxTarget.classList.add("hidden")
      this.lightboxImageTarget.src = ""
      document.body.style.overflow = ""
    }
  }

  confirm(event) {
    event.preventDefault()
    this.updatePreview()
    this.updateHiddenInputs()
    this.close()
  }

  updatePreview() {
    this.previewTarget.innerHTML = ""

    this.selectedImages.forEach((image) => {
      const div = document.createElement("div")
      div.className = "selected-image-thumb"
      if (this.featuredImageId === image.id) {
        div.classList.add("is-featured")
      }
      div.dataset.imageId = image.id

      if (image.url) {
        const img = document.createElement("img")
        img.src = image.url
        img.alt = image.title
        img.dataset.action = "click->gallery-picker#showLightbox"
        img.dataset.fullUrl = image.fullUrl
        img.dataset.title = image.title
        img.style.cursor = "pointer"
        div.appendChild(img)
      }

      const featuredBtn = document.createElement("button")
      featuredBtn.type = "button"
      featuredBtn.className = "featured-image-btn"
      featuredBtn.innerHTML = "&#9733;"
      featuredBtn.title = "Set as card image"
      featuredBtn.dataset.action = "click->gallery-picker#setFeatured"
      featuredBtn.dataset.imageId = image.id
      div.appendChild(featuredBtn)

      const removeBtn = document.createElement("button")
      removeBtn.type = "button"
      removeBtn.className = "remove-image-btn"
      removeBtn.innerHTML = "&times;"
      removeBtn.dataset.action = "click->gallery-picker#removeImage"
      removeBtn.dataset.imageId = image.id
      div.appendChild(removeBtn)

      this.previewTarget.appendChild(div)
    })
  }

  updateHiddenInputs() {
    this.hiddenInputsTarget.innerHTML = ""

    this.selectedImages.forEach((image) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "asset[image_ids][]"
      input.value = image.id
      input.dataset.imageId = image.id
      this.hiddenInputsTarget.appendChild(input)
    })
  }

  removeImage(event) {
    event.preventDefault()
    event.stopPropagation()

    const id = event.currentTarget.dataset.imageId
    this.selectedImages.delete(id)

    // If removing the featured image, clear featured
    if (this.featuredImageId === id) {
      this.featuredImageId = null
      if (this.hasFeaturedInputTarget) {
        this.featuredInputTarget.value = ""
      }
    }

    // Remove from preview
    const thumb = this.previewTarget.querySelector(`[data-image-id="${id}"]`)
    if (thumb) thumb.remove()

    // Remove hidden input
    const input = this.hiddenInputsTarget.querySelector(`[data-image-id="${id}"]`)
    if (input) input.remove()

    // Update modal item state
    const item = this.itemTargets.find(i => i.dataset.imageId === id)
    if (item) item.classList.remove("selected")
  }

  setFeatured(event) {
    event.preventDefault()
    event.stopPropagation()

    const id = event.currentTarget.dataset.imageId
    this.featuredImageId = id

    // Update hidden input
    if (this.hasFeaturedInputTarget) {
      this.featuredInputTarget.value = id
    }

    // Update visual state
    this.previewTarget.querySelectorAll(".selected-image-thumb").forEach(thumb => {
      thumb.classList.remove("is-featured")
    })
    const thumb = this.previewTarget.querySelector(`[data-image-id="${id}"]`)
    if (thumb) {
      thumb.classList.add("is-featured")
    }
  }
}
