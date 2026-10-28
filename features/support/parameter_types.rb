# Aceita "0,00", "50,00", "50.00" e "50" — converte para float.
ParameterType(
  name: 'valor_brl',
  regexp: /(\d+(?:[.,]\d{1,2})?)/,
  transformer: ->(v) { v.tr(',', '.').to_f }
)
