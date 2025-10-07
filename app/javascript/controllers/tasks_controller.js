import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        console.log(this.element)
    }

    toggle(e) {
        const id = e.target.dataset.id
        const csrfToken = document.querySelector("[name='csrf-token']").content

        fetch(`/tasks/${id}/toggle`, {
            method: 'POST',
            mode: 'cors',
            cache: 'no-cache',
            credentials: 'same-origin',
            headers: {
                'Accept': 'text/vnd.turbo-stream.html',
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({ completed: e.target.checked })
        })
        .then(response => response.text())
        .then(html => {
            if (html.trim()) {
                Turbo.renderStreamMessage(html)
            }
        })
        .catch(error => {
            console.error('Erro ao atualizar tarefa:', error)
            e.target.checked = !e.target.checked
        })
    }
}
