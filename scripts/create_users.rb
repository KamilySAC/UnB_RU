# Uso: ruby scripts/create_users.rb [qtd_students] [qtd_employees]
# Padrão: 50 students, 10 employees, users.json na raiz do repositório

require 'json'
require 'securerandom'
require 'set'

STUDENTS_COUNT  = (ARGV[0] || 50).to_i
EMPLOYEES_COUNT = (ARGV[1] || 10).to_i
OUTPUT_PATH     = File.expand_path('../users.json', __dir__)

FIRST_NAMES = %w[
  Ana Beatriz Bruno Camila Carlos Daniel Eduardo Fernanda Gabriel Helena
  Igor Isabela João Juliana Larissa Lucas Mariana Mateus Pedro Rafael
  Sofia Thiago Vitória Letícia Gustavo Amanda Felipe Natália Rodrigo Patrícia
].freeze

LAST_NAMES = %w[
  Silva Santos Oliveira Souza Rodrigues Ferreira Alves Pereira Lima Gomes
  Costa Ribeiro Martins Carvalho Almeida Lopes Soares Fernandes Vieira Barbosa
  Rocha Dias Nascimento Andrade Moreira Nunes Marques Machado Mendes Freitas
].freeze

PASSWORD_LENGTH = 10

def full_name
  middle = rand < 0.5 ? [LAST_NAMES.sample] : []
  [FIRST_NAMES.sample, *middle, LAST_NAMES.sample].join(' ')
end

def password
  SecureRandom.alphanumeric(PASSWORD_LENGTH)
end

def random_digits(count)
  Array.new(count) { rand(10) }.join
end

# 2 dígitos de ano + 2 dígitos de semestre (10 ou 20) + 5 dígitos aleatórios
def student_registration
  year     = format('%02d', rand(17..26))
  semester = [10, 20].sample
  "#{year}#{semester}#{random_digits(5)}"
end

# 7 dígitos aleatórios
def employee_registration
  random_digits(7)
end

def build_users(count)
  seen = Set.new
  Array.new(count) do
    registration = yield
    registration = yield until seen.add?(registration)
    { matricula: registration, nome: full_name, senha: password }
  end
end

users = {
  students: build_users(STUDENTS_COUNT) { student_registration },
  employees: build_users(EMPLOYEES_COUNT) { employee_registration }
}

File.write(OUTPUT_PATH, JSON.pretty_generate(users) + "\n")
puts "#{STUDENTS_COUNT} students e #{EMPLOYEES_COUNT} employees gravados em #{OUTPUT_PATH}"
