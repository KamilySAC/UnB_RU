module HistoricoGlobalHelper
  # R$ 1.234,50
  def formatar_real(valor)
    number_to_currency(valor, unit: "R$ ", separator: ",", delimiter: ".", format: "%u%n")
  end

  # 87,5% (ou traço quando não há acessos)
  def formatar_pontualidade(valor)
    return "—" if valor.nil?

    number_to_percentage(valor, precision: 1, separator: ",")
  end

  # só passagem liberada cobra tarifa; bloqueado/cancelado aparece como R$ 0,00
  def tarifa_cobrada(acesso)
    acesso.liberado? ? acesso.tarifa : 0
  end
end
