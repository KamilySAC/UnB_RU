# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_10_230900) do
  create_table "acessos", force: :cascade do |t|
    t.integer "catraca_id", null: false
    t.string "matricula_discente", null: false
    t.string "turno", null: false
    t.string "modo_validacao", null: false
    t.decimal "tarifa", precision: 8, scale: 2, null: false
    t.integer "status_acesso", null: false
    t.string "status_catraca", null: false
    t.string "motivo_negativa"
    t.datetime "ocorrido_em", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catraca_id", "ocorrido_em"], name: "index_acessos_on_catraca_id_and_ocorrido_em"
    t.index ["catraca_id", "status_acesso"], name: "index_acessos_on_catraca_id_and_status_acesso"
    t.index ["catraca_id", "turno"], name: "index_acessos_on_catraca_id_and_turno"
    t.index ["catraca_id"], name: "index_acessos_on_catraca_id"
  end

  create_table "acessos_catraca", force: :cascade do |t|
    t.integer "estudante_id"
    t.string "identificacao_lida"
    t.string "turno", null: false
    t.date "data", null: false
    t.decimal "valor_debitado", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "isento", default: false, null: false
    t.string "status_catraca", default: "bloqueada", null: false
    t.string "status_acesso", default: "pendente", null: false
    t.string "mensagem_visor"
    t.index ["estudante_id"], name: "index_acessos_catraca_on_estudante_id"
  end

  create_table "catracas", force: :cascade do |t|
    t.integer "restaurante_id", null: false
    t.string "codigo", null: false
    t.string "nome", null: false
    t.integer "piso", default: 1, null: false
    t.integer "status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurante_id", "codigo"], name: "index_catracas_on_restaurante_id_and_codigo", unique: true
    t.index ["restaurante_id", "piso"], name: "index_catracas_on_restaurante_id_and_piso"
    t.index ["restaurante_id"], name: "index_catracas_on_restaurante_id"
  end

  create_table "estudantes", force: :cascade do |t|
    t.string "nome", null: false
    t.string "matricula", null: false
    t.string "curso"
    t.string "turno"
    t.string "campus"
    t.string "grupo", default: "Grupo II", null: false
    t.decimal "saldo", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matricula"], name: "index_estudantes_on_matricula", unique: true
  end

  create_table "recargas", force: :cascade do |t|
    t.integer "estudante_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.string "forma", default: "PIX", null: false
    t.string "status", default: "Aprovada", null: false
    t.date "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estudante_id"], name: "index_recargas_on_estudante_id"
  end

  create_table "refeicoes", force: :cascade do |t|
    t.integer "estudante_id", null: false
    t.string "restaurante", default: "RU Darcy Ribeiro", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estudante_id"], name: "index_refeicoes_on_estudante_id"
  end

  create_table "restaurantes", force: :cascade do |t|
    t.string "codigo", null: false
    t.string "nome", null: false
    t.string "campus"
    t.integer "capacidade_por_hora", default: 0, null: false
    t.integer "total_pisos", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_restaurantes_on_codigo", unique: true
  end

  add_foreign_key "acessos", "catracas"
  add_foreign_key "acessos_catraca", "estudantes"
  add_foreign_key "catracas", "restaurantes"
  add_foreign_key "recargas", "estudantes"
  add_foreign_key "refeicoes", "estudantes"
end
