class HistoricosController < ApplicationController
    # desativa temporariamente a verificação de navegadores para facilitar testes
    allow_browser versions: :all if respond_to? (:allow_browser)

    # ação responsável por gersr e disparar o download do PDF
    # GET /historico/exportar_pdf
    def exportar_pdf
      estudante = current_estudante

      # se não houver discente autenticado, barra o acesso
      unless estudante
        flash[:alert] = "Você precisa estar autenticado como estudante"
        return redirect_to root_path
      end

      # instancia o gerador de pdf passando o estudante como parâmetro
      gerador = GeradorHistoricoPdf.new(estudante)

      # regra: se possuir movimentações no mes atual, faz o download
      if gerador.possui_movimentacoes?
        pdf_data = gerador.gerar
        send_data pdf_data,
        filename: GeradorHistoricoPdf::NOME_ARQUIVO,
        type: "application/pdf", # define o tipo de arquivo
        disposition: "attachment" # força o download
      else
        # caminho triste: sem movimentações no mês atual - nenhum download e exibe mensagem
        flash[:alert] = "Não há movimentações registradas no mês atual."
        render plain: "Não há movimentações registradas no mês atual", status: :unprocessable_entity
      end
    end


    private
    # retorna o estudante autenticado na sessão (ou primeiro para testes)
    def current_estudante
      @current_estudante ||= Estudante.find_by(id: session[:estudante_id]) || Estudante.first
    end
end
