require "rails_helper"

RSpec.describe "Acessos", type: :request do
  let(:restaurante) do
    Restaurante.create!(
      codigo: "RU-TESTE",
      nome: "Restaurante de teste",
      capacidade_por_hora: 100,
      total_pisos: 2
    )
  end

  let(:catraca) do
    restaurante.catracas.create!(
      codigo: "CAT-01",
      nome: "Catraca 01",
      piso: 1,
      status: :online
    )
  end

  def criar_acesso(catraca, **atributos)
    catraca.acessos.create!({
      matricula_discente: "MAT-TESTE",
      turno: "Almoço",
      modo_validacao: "Cartão",
      tarifa: 2.50,
      status_acesso: :liberado,
      status_catraca: :online,
      ocorrido_em: Time.current
    }.merge(atributos))
  end

  describe "GET /catracas/:catraca_id/acessos" do
    it "exibe os dados do histórico da catraca" do
      criar_acesso(catraca)

      get catraca_acessos_path(catraca)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("MAT-TESTE", "Cartão", "Almoço", "Status da catraca")
    end

    it "não inclui acessos de outra catraca" do
      acesso_da_catraca = criar_acesso(catraca, matricula_discente: "MAT-CORRETA")
      outra_catraca = restaurante.catracas.create!(
        codigo: "CAT-02",
        nome: "Catraca 02",
        piso: 2,
        status: :online
      )
      criar_acesso(outra_catraca, matricula_discente: "MAT-OUTRA")

      get catraca_acessos_path(catraca)

      expect(response.body).to include(acesso_da_catraca.matricula_discente)
      expect(response.body).not_to include("MAT-OUTRA")
    end

    it "aplica os filtros por data, turno e status" do
      criar_acesso(catraca, matricula_discente: "MAT-BLOQUEADA", status_acesso: :bloqueado, motivo_negativa: "Saldo insuficiente")
      criar_acesso(catraca, matricula_discente: "MAT-LIBERADA", status_acesso: :liberado)

      get catraca_acessos_path(catraca), params: {
        data: Date.current.iso8601,
        turno: "Almoço",
        status: "bloqueado"
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("MAT-BLOQUEADA")
      expect(response.body).not_to include("MAT-LIBERADA")
    end

    it "retorna bad request para um status desconhecido" do
      get catraca_acessos_path(catraca), params: { status: "desconhecido" }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "GET /catracas/:catraca_id/acessos/new" do
    it "exibe o formulário de registro manual" do
      get new_catraca_acesso_path(catraca)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Registrar acesso", "Matrícula do discente")
    end
  end

  describe "POST /catracas/:catraca_id/acessos" do
    let(:parametros_validos) do
      {
        matricula_discente: "MAT-NOVA",
        turno: "Almoço",
        modo_validacao: "Cartão",
        tarifa: "2.50",
        status_acesso: "liberado",
        status_catraca: "online",
        ocorrido_em: Time.current.iso8601
      }
    end

    it "registra o acesso e redireciona ao histórico" do
      expect do
        post catraca_acessos_path(catraca), params: { acesso: parametros_validos }
      end.to change(Acesso, :count).by(1)

      expect(response).to redirect_to(catraca_acessos_path(catraca))
    end

    it "reexibe o formulário quando uma tentativa bloqueada não tem motivo" do
      parametros_invalidos = parametros_validos.merge(status_acesso: "bloqueado")

      expect do
        post catraca_acessos_path(catraca), params: { acesso: parametros_invalidos }
      end.not_to change(Acesso, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Motivo da negativa")
    end
  end
end
