require "rails_helper"

RSpec.describe "Gestão de restaurantes e catracas", type: :request do
  let(:restaurante) do
    Restaurante.create!(
      codigo: "RU-TESTE",
      nome: "Restaurante de teste",
      capacidade_por_hora: 100,
      total_pisos: 2
    )
  end

  describe "restaurantes" do
    it "lista restaurantes e catracas associadas" do
      restaurante.catracas.create!(codigo: "CAT-01", nome: "Catraca 01", piso: 1, status: :online)

      get restaurantes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Restaurante de teste", "Catraca 01", "Adicionar catraca")
    end

    it "cria um restaurante válido" do
      parametros = {
        codigo: "RU-NOVO",
        nome: "RU Novo",
        campus: "Darcy Ribeiro",
        capacidade_por_hora: 100,
        total_pisos: 2
      }

      expect do
        post restaurantes_path, params: { restaurante: parametros }
      end.to change(Restaurante, :count).by(1)

      expect(response).to redirect_to(restaurantes_path)
    end

    it "rejeita restaurante sem nome" do
      expect do
        post restaurantes_path, params: {
          restaurante: { codigo: "RU-SEM-NOME", capacidade_por_hora: 100, total_pisos: 2 }
        }
      end.not_to change(Restaurante, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Nome")
    end

    it "rejeita nome duplicado e atualiza o restaurante" do
      restaurante

      expect do
        post restaurantes_path, params: {
          restaurante: { codigo: "RU-DUP", nome: restaurante.nome, capacidade_por_hora: 100, total_pisos: 2 }
        }
      end.not_to change(Restaurante, :count)
      expect(response).to have_http_status(:unprocessable_content)

      patch restaurante_path(restaurante), params: { restaurante: { nome: "RU Atualizado" } }
      expect(response).to redirect_to(restaurantes_path)
      expect(restaurante.reload.nome).to eq("RU Atualizado")
    end
  end

  describe "catracas" do
    let(:parametros_validos) do
      { codigo: "CAT-NOVA", nome: "Catraca Nova", piso: 1, status: "online" }
    end

    it "cria catraca associada ao restaurante" do
      expect do
        post restaurante_catracas_path(restaurante), params: { catraca: parametros_validos }
      end.to change(Catraca, :count).by(1)

      expect(response).to redirect_to(restaurantes_path)
      expect(restaurante.catracas.last.nome).to eq("Catraca Nova")
    end

    it "rejeita catraca em piso acima do total do restaurante" do
      expect do
        post restaurante_catracas_path(restaurante), params: {
          catraca: parametros_validos.merge(piso: 3)
        }
      end.not_to change(Catraca, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "atualiza o estado da catraca" do
      catraca = restaurante.catracas.create!(parametros_validos)

      patch catraca_path(catraca), params: { catraca: { status: "offline" } }

      expect(response).to redirect_to(restaurantes_path)
      expect(catraca.reload.status).to eq("offline")
    end

    it "retorna not found ao abrir cadastro para restaurante inexistente" do
      expect do
        get new_restaurante_catraca_path(restaurante_id: -1)
      end.not_to change(Catraca, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
