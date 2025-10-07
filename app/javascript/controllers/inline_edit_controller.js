import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text", "input", "form"]
  static values = { taskId: Number, originalText: String }

  connect() {
    this.originalTextValue = this.textTarget.textContent.trim()
  }

  startEdit() {
    this.textTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    
    this.inputTarget.value = this.originalTextValue
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  handleKeydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.saveEdit()
    } else if (event.key === "Escape") {
      event.preventDefault()
      this.cancelEdit()
    }
  }

  handleBlur() {
    setTimeout(() => {
      if (document.activeElement !== this.inputTarget) {
        this.saveEdit()
      }
    }, 100)
  }

  saveEdit() {
    const newText = this.inputTarget.value.trim()
    
    if (newText === this.originalTextValue) {
      this.cancelEdit()
      return
    }

    if (newText === "") {
      this.inputTarget.focus()
      return
    }

    const csrfToken = document.querySelector("[name='csrf-token']").content
    
    fetch(`/tasks/${this.taskIdValue}`, {
      method: 'PATCH',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        task: {
          description: newText
        }
      })
    })
    .then(response => response.text())
    .then(html => {
      if (html.trim()) {
        Turbo.renderStreamMessage(html)
      }
    })
    .catch(error => {
      console.error('Erro ao atualizar tarefa:', error)
      this.cancelEdit()
      alert('Erro ao salvar. Tente novamente.')
    })
  }

  cancelEdit() {
    this.inputTarget.classList.add("hidden")
    this.textTarget.classList.remove("hidden")
    this.inputTarget.value = this.originalTextValue
  }
}
