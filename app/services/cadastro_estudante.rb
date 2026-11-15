# Recebe matrícula, nome, senha e confirmação; cria a conta se as regras forem respeitadas.
class CadastroEstudante
  MSG_CAMPOS_OBRIGATORIOS = "Todos os campos devem ser preenchidos".freeze
  MSG_SENHAS_DIFERENTES   = "As senhas não são iguais".freeze
  MSG_MATRICULA_EXISTENTE = "Matrícula já cadastrada".freeze
  MSG_SENHA_MUITO_LONGA   = "A senha deve ter no máximo 72 caracteres".freeze
  MSG_SUCESSO             = "Cadastro realizado com sucesso! Sua conta foi criada.".freeze

  LIMITE_BYTES_SENHA = 72

  attr_reader :estudante, :erros, :matricula, :nome

  def initialize(matricula:, nome:, senha:, confirmacao_senha:)
    @matricula = matricula.to_s.strip
    @nome = nome.to_s.strip
    @senha = senha.to_s
    @confirmacao_senha = confirmacao_senha.to_s
    @erros = []
    @estudante = nil
  end

  def call
    @erros = validar
    return false if @erros.any?

    criar_estudante
  end

  def sucesso?
    @estudante.present? && @erros.empty?
  end

  private

  def validar
    # campo vazio: nenhuma outra verificação faz sentido, a conta não é criada
    return [ MSG_CAMPOS_OBRIGATORIOS ] if campo_vazio?

    erros = []
    erros << MSG_SENHAS_DIFERENTES if @senha != @confirmacao_senha
    erros << MSG_SENHA_MUITO_LONGA if @senha.bytesize > LIMITE_BYTES_SENHA
    erros << MSG_MATRICULA_EXISTENTE if Estudante.exists?(matricula: @matricula)
    erros
  end

  def campo_vazio?
    [ @matricula, @nome, @senha, @confirmacao_senha ].any?(&:blank?)
  end

  def criar_estudante
    @estudante = Estudante.new(
      matricula: @matricula,
      nome: @nome,
      password: @senha,
      password_confirmation: @confirmacao_senha
    )

    if @estudante.save
      true
    else
      @erros = @estudante.errors.full_messages
      @estudante = nil
      false
    end
  rescue ActiveRecord::RecordNotUnique
    @erros = [ MSG_MATRICULA_EXISTENTE ]
    @estudante = nil
    false
  end
end
