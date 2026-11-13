# Recebe matrícula, nome, senha e confirmação; cria a conta se as regras forem respeitadas.
class CadastroEstudante
  MSG_CAMPOS_OBRIGATORIOS = "Todos os campos devem ser preenchidos".freeze
  MSG_SENHAS_DIFERENTES   = "As senhas não são iguais".freeze
  MSG_MATRICULA_EXISTENTE = "Matrícula já cadastrada".freeze
  MSG_SUCESSO             = "Cadastro realizado com sucesso! Sua conta foi criada.".freeze

  attr_reader :estudante, :erros, :matricula, :nome

  def initialize(matricula:, nome:, senha:, confirmacao_senha:)
    # TODO: guardar os dados (matricula e nome com strip) e iniciar @erros = []
  end

  # TODO: validar e criar a conta; true se criou, false (com @erros) se não
  def call
  end

  # TODO: true quando a conta foi criada
  def sucesso?
  end

  private

  # TODO: lista de mensagens de erro (campos vazios, senhas diferentes, matrícula repetida)
  def validar
  end

  # TODO: true se algum campo estiver em branco
  def campo_vazio?
  end

  # TODO: Estudante.new + save, tratando matrícula duplicada
  def criar_estudante
  end
end