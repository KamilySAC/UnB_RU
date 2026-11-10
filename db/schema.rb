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

ActiveRecord::Schema[8.1].define(version: 2026_06_01_000001) do
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

  add_foreign_key "acessos_catraca", "estudantes"
  add_foreign_key "recargas", "estudantes"
  add_foreign_key "refeicoes", "estudantes"
end
