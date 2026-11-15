class CreateValidacaoEntradaTables < ActiveRecord::Migration[8.1]
  def change
    #--- cria tabela de estudantes, armazena dados básicos de estudantes, grupo e saldo ---
    create_table(:estudantes, if_not_exists: true) do |t|
      t.string :nome, null: false # nome completo do estudante
      t.string :matricula, null: false # matricula do estudante
      t.string :curso # curso do estudante
      t.string :turno # turno do estudante
      t.string :campus # campus do estudante
      t.string :grupo, default: "Grupo II", null: false # tipo do estudante
      t.decimal :saldo, precision: 10, scale: 2, default: 0.0, null: false # saldo do estudante
      t.timestamps # timestamps
    end

    # adiciona indice na coluna matricula, que não haja duas contas com a mesma matrícula
    add_index(:estudantes, :matricula, unique: true, if_not_exists: true)


    # --- cria tabela de acessos_catraca ---
    # registra leitura, tentativas e giros físicos


    create_table :acessos_catraca, if_not_exists: true do |t|
      # vincula ao estudante cadastrado
      t.references :estudante, null: true, foreign_key: true # foreign key para estudantes

      t.string :identificacao_lida # numero lido pelo leitor

      t.string :turno, null: false # cafe da manha, almoço e janta

      t.date :data, null: false # data de acesso a catraca (para anti-passback)

      # valor a ser debitado
      t.decimal :valor_debitado, precision: 10, scale: 2, default: 0.0, null: false

      t.boolean :isento, default: false, null: false # true para grupo I, isenção

      # estados da trava da catraca
      t.string :status_catraca, null: false, default: "bloqueada"

      # Estados do fluxo de validacao:
      # "pendente" - leitura inicial
      # "aguardando_giro" - liberada para passagem (timeout de 5 seg)
      # "registrado" - giro confirmado e saldo debitado
      # "isento" - giro confirmado para isentos, sem débito
      # "cancelado" - timeout de 5 seg atingido
      # "negado" - saldo insuficiente, usuario. não cadastrado ou repeticao de turno.
      t.string :status_acesso, null: false, default: "pendente"

      # mensagem de retorno da catraca
      t.string :mensagem_visor
    end
  end
end
