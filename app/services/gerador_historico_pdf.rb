# a gem prawn, responsável por desenhar e renderizar pdf em ruby
require "prawn"
Prawn::Fonts::AFM.hide_m17n_warning = true

# Responsável por consultar as movimentações financeiras (recargas e refeições)
# do estudante estritamente no mês vigente, calcular os totais consolidados
# e renderizar o documento PDF em formato A4 utilizando a gem Prawn.
class GeradorHistoricoPdf
  # Nome padrão do arquivo PDF gerado para download.
  NOME_ARQUIVO = "historico_estudante.pdf".freeze

  # cria getters, os dados do relatório fora da classe
  attr_reader :estudante, :data_referencia, :inicio_mes, :fim_mes, :recargas, :refeicoes

  # Inicializa o gerador filtrando automaticamente as recargas e refeições do mês de referência.
  #
  # Prepara consultas ActiveRecord filtradas por +beginning_of_month..end_of_month+ sem alterar dados no banco.
  #
  # @param estudante [Estudante] instância do discente autenticado.
  # @param data_referencia [Date] data base para determinar o mês vigente (padrão: +Date.current+).
  # @return [GeradorHistoricoPdf] nova instância configurada com o intervalo mensal e consultas filtradas.
  def initialize(estudante, data_referencia: Date.current) # constructor
    @estudante = estudante
    @data_referencia = data_referencia

    @inicio_mes = data_referencia.beginning_of_month # retorna o primeiro dia do mes
    @fim_mes = data_referencia.end_of_month # retorna o ultimo dia do mes

    # filtra as movimentações no intervalo do mes atual, qualquer recarga feita anteriormente é desconsiderada da consulta do banco
    @recargas = estudante.recargas.where(data: @inicio_mes..@fim_mes).order(:data)
    @refeicoes = estudante.refeicoes.where(data: @inicio_mes..@fim_mes).order(:data)
  end

  # Verifica se o estudante possui ao menos uma recarga ou refeição registrada no mês atual.
  #
  # Executa consulta +EXISTS+ somente leitura no banco de dados, sem efeitos colaterais.
  #
  # @return [Boolean] +true+ se houver recargas ou refeições no mês vigente, +false+ caso contrário.
  def possui_movimentacoes?
    recargas.exists? || refeicoes.exists?
  end

  # Calcula o valor total recarregado pelo estudante dentro do mês de referência.
  #
  # Executa consulta +SUM+ somente leitura em +recargas+, sem efeitos colaterais.
  #
  # @return [BigDecimal] soma das recargas do mês arredondada em 2 casas decimais.
  def total_recarregado
    BigDecimal(recargas.sum(:valor).to_s).round(2)
  end

  # Calcula o valor total consumido em refeições pelo estudante dentro do mês de referência.
  #
  # Executa consulta +SUM+ somente leitura em +refeicoes+, sem efeitos colaterais.
  #
  # @return [BigDecimal] soma das refeições do mês arredondada em 2 casas decimais.
  def total_consumido
    BigDecimal(refeicoes.sum(:valor).to_s).round(2)
  end


  # Gera e renderiza o binário do relatório em PDF (formato A4) com os dados do mês atual.
  #
  # Sem efeitos colaterais no banco de dados (apenas leitura e geração em memória).
  #
  # @return [String, nil] string binária do arquivo PDF (+application/pdf+) caso existam movimentações no mês,
  #   ou +nil+ caso o estudante não possua movimentações registradas no mês vigente.
  def gerar
    # se não houver nenhuma movimentação no mês, cancela a geração do pdf
    return nil unless possui_movimentacoes?

    # inicializa uma folha A4 com margem de 40 pontos
    pdf = Prawn::Document.new(page_size: "A4", margin: 40)

    # chama cada seção separada para montar o documento sem inflar um método só
    desenhar_cabecalho(pdf)
    desenhar_dados_discente(pdf)
    desenhar_resumo_financeiro(pdf)
    desenhar_extrato_recargas(pdf)
    desenhar_historico_refeicoes(pdf)

    # converte o documento desenhado em binário de arquivo PDF
    pdf.render
  end

  # cria-se métodos privados para modularizar o código e refatorar
  private

  # retorna o mês e ano formatados (ex: "11/2026") sem repetir strftime
  def mes_referencia
    data_referencia.strftime("%m/%Y")
  end

  # formata qualquer valor numérico em moeda brasileira com vírgula (ex: "R$ 20,00")
  def formatar_moeda(valor)
    "R$ #{format('%.2f', valor).tr('.', ',')}"
  end

  # desenha o subtítulo padrão de uma seção com linha divisória horizontal
  def desenhar_titulo_secao(pdf, titulo)
    pdf.text titulo, size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 5
  end

  # 1. desenha o cabeçalho institucional no topo do relatório
  def desenhar_cabecalho(pdf)
    pdf.text "Restaurante Universitário | UnB", size: 18, style: :bold, align: :center
    pdf.text "Extrato e Histórico de Refeições", size: 14, align: :center
    pdf.text "Mês de Referência: #{mes_referencia}", size: 10, align: :center, color: "555555"
    pdf.move_down 20
  end

  # 2. desenha os dados cadastrais do estudante e o saldo atual
  def desenhar_dados_discente(pdf)
    desenhar_titulo_secao(pdf, "Dados do Discente")
    linhas_discente.each { |linha| pdf.text linha }
    pdf.text "Saldo Atual: #{formatar_moeda(estudante.saldo)}", style: :bold
    pdf.move_down 15
  end

  # monta as linhas de identificação cadastral do discente
  def linhas_discente
    [
      "Nome: #{estudante.nome}",
      "Matrícula: #{estudante.matricula}",
      "Grupo Tarifário: #{estudante.grupo}"
    ]
  end

  # 3. desenha os totais recarregado e consumido no mês vigente
  def desenhar_resumo_financeiro(pdf)
    desenhar_titulo_secao(pdf, "Resumo Financeiro do Mês (#{mes_referencia})")
    pdf.text "Total Recarregado no Mês: #{formatar_moeda(total_recarregado)}"
    pdf.text "Total Consumido no Mês: #{formatar_moeda(total_consumido)}"
    pdf.move_down 20
  end

  # 4. desenha a seção de recargas do mês atual
  def desenhar_extrato_recargas(pdf)
    desenhar_titulo_secao(pdf, "Extrato de Recargas do Mês")
    desenhar_lista(pdf, recargas, "Nenhuma recarga realizada neste mês.") { |recarga| texto_recarga(recarga) }
    pdf.move_down 15
  end

  # 5. desenha a seção de refeições do mês atual
  def desenhar_historico_refeicoes(pdf)
    desenhar_titulo_secao(pdf, "Histórico de Refeições do Mês")
    desenhar_lista(pdf, refeicoes, "Nenhuma refeição consumida neste mês.") { |refeicao| texto_refeicao(refeicao) }
  end

  # percorre uma lista de registros ou escreve a mensagem em itálico se estiver vazia
  def desenhar_lista(pdf, registros, mensagem_vazia)
    if registros.any?
      registros.each { |registro| pdf.text yield(registro) }
    else
      pdf.text mensagem_vazia, style: :italic, color: "777777"
    end
  end

  # monta o texto formatado de uma linha de recarga
  def texto_recarga(recarga)
    "#{recarga.data.strftime('%d/%m/%Y')} - #{recarga.forma} - #{formatar_moeda(recarga.valor)} (#{recarga.status})"
  end

  # monta o texto formatado de uma linha de refeição
  def texto_refeicao(refeicao)
    "#{refeicao.data.strftime('%d/%m/%Y')} - #{refeicao.restaurante} - #{formatar_moeda(refeicao.valor)}"
  end
end
