import { Controller } from "@hotwired/stimulus"

// alterna a senha entre oculta e em texto
export default class extends Controller {
  static targets = ["campo", "botao"]

  connect() {

    this.element.dataset.senhaPronto = "true"
  }

  alternar() {
    const estavaVisivel = this.campoTarget.type === "text"
    const rotulo = estavaVisivel ? "Mostrar senha" : "Ocultar senha"

    this.campoTarget.type = estavaVisivel ? "password" : "text"
    this.botaoTarget.textContent = estavaVisivel ? "Mostrar" : "Ocultar"
    this.botaoTarget.title = rotulo
    this.botaoTarget.setAttribute("aria-label", rotulo)
    this.botaoTarget.setAttribute("aria-pressed", String(!estavaVisivel))
  }
}