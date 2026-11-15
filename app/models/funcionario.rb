# funcionário do restaurante que opera ou administra o sistema (fiscal ou administrador)
class Funcionario < ApplicationRecord
  PAPEIS = %w[fiscal administrador].freeze

  # senha criptografada (bcrypt); nunca guardamos a senha em texto
  has_secure_password

  before_validation :normalizar_campos

  validates :nome, presence: true
  validates :matricula_siape, presence: true, uniqueness: true,
                              format: { with: /\A\d{7}\z/, message: "deve ter 7 dígitos" }
  # usuário é opcional; precisa ter ao menos uma letra para não se confundir com a matrícula
  validates :usuario, uniqueness: true, allow_nil: true,
                      format: { with: /\A(?=.*[a-z])[a-z0-9._-]{3,30}\z/ }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :papel, inclusion: { in: PAPEIS }

  def fiscal?
    papel == "fiscal"
  end

  def administrador?
    papel == "administrador"
  end

  # autentica por matrícula SIAPE ou usuário; devolve o funcionário ou nil
  def self.autenticar(identificador, senha)
    identificador = identificador.to_s.strip
    registro = find_by(matricula_siape: identificador) || find_by(usuario: identificador.downcase)

    if registro
      registro.authenticate(senha.to_s) || nil
    else
      # gera o hash mesmo sem achar o funcionário, para o tempo de resposta não revelar se ele existe
      new(password: senha.to_s)
      nil
    end
  end

  private

  def normalizar_campos
    self.matricula_siape = matricula_siape.to_s.strip
    self.usuario = usuario.to_s.strip.downcase.presence
  end
end