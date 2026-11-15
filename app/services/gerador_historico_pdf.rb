# a gem prawn, responsável por desenhar e renderizar pdf em ruby
require "prawn"
Prawn::Fonts::AFM.hide_m17n_warning = true


class GeradorHistoricoPdf
  NOME_ARQUIVO = "historico_estudante.pdf".freeze

  # cria getters, os dados do relatório fora da classe
  attr_reader :estudante, :data_referencia, :inicio_mes, :fim_mes, :recargas, :refeicoes

  def initialize(estudante, data_referencia: Date.current) # constructor
    @estudante = estudante
    @data_referencia = data_referencia

    @inicio_mes = data_referencia.beginning_of_month # retorna o primeiro dia do mes
    @fim_mes = data_referencia.end_of_month # retorna o ultimo dia do mes

    # filtra as movimentações no intervalo do mes atual, qualquer recarga feita anteriormente é desconsiderada da consulta do banco
    @recargas = estudante.recargas.where(data: @inicio_mes..@fim_mes).order(:data)
    @refeicoes = estudante.refeicoes.where(data: @inicio_mes..@fim_mes).order(:data)
  end

  # função de possui movimentações, retorna true se houver recargas ou refeições no mes atual
  def possui_movimentacoes?
    recargas.exists? || refeicoes.exists?
  end


  # função de total recarregado, retorna a soma dos valores de recarga
  def total_recarregado
    BigDecimal(recargas.sum(:valor).to_s).round(2)
  end


  # função de total consumido, retorna a soma dos valores gastos
  def total_consumido
    BigDecimal(refeicoes.sum(:valor).to_s).round(2)
  end


  def gerar
    # se não houver nenhuma movimentação no mes, cancela a geração do pdf
    return nil unless possui_movimentacoes?

    # inicializa uma folha A4 com margend de 40 pontos
    pdf = Prawn::Document.new(page_size: "A4", margin: 40)

    # 1. cabeçalho de relatório
    pdf.text "Restaurante Universitário | UnB", size: 18, style: :bold, align: :center

    pdf.text "Extrato e Histórico de Refeições", size: 14, align: :center
    # Exibe o mês e ano de vigência (ex: "11/2026")
    pdf.text "Mês de Referência: #{data_referencia.strftime('%m/%Y')}", size: 10, align: :center, color: "555555"

    pdf.move_down 20 # Espaçamento vertical


    # 2. Dados do Discente e Saldo Atual
    pdf.text "Dados do Discente", size: 12, style: :bold
    pdf.stroke_horizontal_rule # Linha divisória horizontal
    pdf.move_down 5
    pdf.text "Nome: #{estudante.nome}"
    pdf.text "Matrícula: #{estudante.matricula}"
    pdf.text "Grupo Tarifário: #{estudante.grupo}"
    # Formata moeda com vírgula (ex: 20,00)
    pdf.text "Saldo Atual: R$ #{format('%.2f', estudante.saldo).tr('.', ',')}", style: :bold
    pdf.move_down 15


    # 3. Resumo Financeiro (do mes vigente)
    pdf.text "Resumo Financeiro do Mês (#{data_referencia.strftime('%m/%Y')})", size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 5
    pdf.text "Total Recarregado no Mês: R$ #{format('%.2f', total_recarregado).tr('.', ',')}"
    pdf.text "Total Consumido no Mês: R$ #{format('%.2f', total_consumido).tr('.', ',')}"
    pdf.move_down 20


    # 4. Detalhamento das recargas do mês atual
    pdf.text "Extrato de Recargas do Mês", size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 5
    if recargas.any?
      recargas.each do |recarga|
        pdf.text "#{recarga.data.strftime('%d/%m/%Y')} - #{recarga.forma} - R$ #{format('%.2f', recarga.valor).tr('.', ',')} (#{recarga.status})"
      end
    else
      pdf.text "Nenhuma recarga realizada neste mês.", style: :italic, color: "777777"
    end
    pdf.move_down 15


  # 5. Detalhamento das refeições do mês atual
  pdf.text "Histórico de Refeições do Mês", size: 12, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 5
    if refeicoes.any?
      refeicoes.each do |refeicao|
        pdf.text "#{refeicao.data.strftime('%d/%m/%Y')} - #{refeicao.restaurante} - R$ #{format('%.2f', refeicao.valor).tr('.', ',')}"
      end
    else
      pdf.text "Nenhuma refeição consumida neste mês.", style: :italic, color: "777777"
    end
    # .render converte o documento desenhado em binário de arquivo PDF
    pdf.render
  end
end
