require "rails_helper"

RSpec.describe "Terminal de Validação", type: :request do
  let!(:fiscal) do
    Funcionario.create!(
      nome: "Fulano D.",
      matricula_siape: "2948102",
      password: "Senha@123",
      papel: "fiscal"
    )
  end

  let!(:restaurante) do
    Restaurante.create!(
      codigo: "RU-DARCY",
      nome: "RU Darcy Ribeiro",
      capacidade_por_hora: 500,
      total_pisos: 2
    )
  end

  let!(:catraca) do
    restaurante.catracas.create!(
      codigo: "CAT-01",
      nome: "Catraca Principal",
      piso: 1,
      status: :online
    )
  end

  describe "sem funcionário autenticado" do
    it "redireciona para a tela de login do funcionário" do
      get terminal_validacao_path

      expect(response).to redirect_to(login_funcionario_path)
    end
  end

  describe "com funcionário autenticado" do
    before do
      post login_funcionario_path, params: { identificador: "2948102", senha: "Senha@123" }
    end

    it "exibe a tela do Terminal de Validação com o operador e as catracas" do
      get terminal_validacao_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Terminal de Validação", "Fulano D.", "Catraca Principal")
    end

    it "alerta quando a matrícula não é informada" do
      post validar_entrada_terminal_path, params: { identificacao: "   ", turno: "Almoço", catraca_id: catraca.id }

      expect(response).to redirect_to(terminal_validacao_path(catraca_id: catraca.id, turno: "Almoço"))
      expect(flash[:alert]).to eq("Informe a matrícula do estudante.")
    end

    it "bloqueia matrícula inexistente e registra o acesso bloqueado na catraca física" do
      expect {
        post validar_entrada_terminal_path, params: {
          identificacao: "999999999",
          turno: "Almoço",
          catraca_id: catraca.id
        }
      }.to change(AcessoCatraca, :count).by(1).and change(Acesso, :count).by(1)

      acesso_catraca = AcessoCatraca.last
      acesso_fisico = Acesso.last

      expect(acesso_catraca.status_acesso).to eq("negado")
      expect(acesso_catraca.mensagem_visor).to eq("Usuário não encontrado")
      expect(acesso_fisico.status_acesso).to eq("bloqueado")
      expect(acesso_fisico.motivo_negativa).to eq("Usuário não encontrado")
      expect(flash[:alert]).to eq("Usuário não encontrado")
    end

    it "valida e conclui o giro de estudante pagante debitando saldo e integrando refeição e histórico da catraca" do
      estudante = Estudante.create!(nome: "Arthur", matricula: "242009990", grupo: "Grupo II", saldo: 10.00)

      post validar_entrada_terminal_path, params: {
        identificacao: estudante.matricula,
        turno: "Almoço",
        catraca_id: catraca.id
      }

      acesso_catraca = AcessoCatraca.last
      expect(acesso_catraca.status_acesso).to eq("aguardando_giro")
      expect(estudante.reload.saldo.to_f).to eq(10.00)
      expect(response).to redirect_to(
        terminal_validacao_path(acesso_id: acesso_catraca.id, catraca_id: catraca.id, turno: "Almoço")
      )

      follow_redirect!
      expect(response.body).to include("Catraca liberada", "Confirmar giro da catraca")

      expect {
        post registrar_giro_terminal_path(acesso_catraca), params: { catraca_id: catraca.id }
      }.to change(Refeicao, :count).by(1).and change(Acesso, :count).by(1)

      expect(estudante.reload.saldo.to_f).to eq(5.50)
      expect(acesso_catraca.reload.status_acesso).to eq("registrado")

      refeicao = Refeicao.last
      expect(refeicao.estudante).to eq(estudante)
      expect(refeicao.restaurante).to eq("RU Darcy Ribeiro")
      expect(refeicao.valor.to_f).to eq(4.50)

      acesso_fisico = Acesso.last
      expect(acesso_fisico.status_acesso).to eq("liberado")
      expect(acesso_fisico.tarifa.to_f).to eq(4.50)
      expect(flash[:notice]).to eq("Refeição efetuada com sucesso")
    end

    it "valida e conclui o giro de estudante isento sem criar refeição paga e registra acesso liberado" do
      estudante = Estudante.create!(nome: "Maria Isenta", matricula: "241000111", grupo: "Grupo I", saldo: 0.00)

      post validar_entrada_terminal_path, params: {
        identificacao: estudante.matricula,
        turno: "Jantar",
        catraca_id: catraca.id
      }
      acesso_catraca = AcessoCatraca.last

      expect {
        post registrar_giro_terminal_path(acesso_catraca), params: { catraca_id: catraca.id }
      }.to change(Acesso, :count).by(1).and change(Refeicao, :count).by(0)

      expect(estudante.reload.saldo.to_f).to eq(0.00)
      expect(acesso_catraca.reload.status_acesso).to eq("isento")
      expect(Acesso.last.tarifa.to_f).to eq(0.0)
      expect(flash[:notice]).to eq("Acesso Liberado - Isento")
    end

    it "impede registrar giro quando a catraca não está aguardando giro" do
      estudante = Estudante.create!(nome: "Carlos", matricula: "242000222", grupo: "Grupo II", saldo: 0.00)
      acesso_negado = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")

      post registrar_giro_terminal_path(acesso_negado), params: { catraca_id: catraca.id }

      expect(response).to redirect_to(
        terminal_validacao_path(acesso_id: acesso_negado.id, catraca_id: catraca.id, turno: "Almoço")
      )
      expect(flash[:alert]).to eq("Catraca não está liberada.")
    end

    it "cancela a liberação por timeout sem debitar saldo e registra acesso cancelado na catraca" do
      estudante = Estudante.create!(nome: "João Timeout", matricula: "242000333", grupo: "Grupo II", saldo: 10.00)

      post validar_entrada_terminal_path, params: {
        identificacao: estudante.matricula,
        turno: "Almoço",
        catraca_id: catraca.id
      }
      acesso_catraca = AcessoCatraca.last

      expect {
        post timeout_terminal_path(acesso_catraca), params: { catraca_id: catraca.id }
      }.to change(Acesso, :count).by(1).and change(Refeicao, :count).by(0)

      expect(estudante.reload.saldo.to_f).to eq(10.00)
      expect(acesso_catraca.reload.status_acesso).to eq("cancelado")
      expect(Acesso.last.status_acesso).to eq("cancelado")
      expect(flash[:alert]).to eq("Tempo esgotado - Catraca bloqueada")
    end

    it "informa erro ao tentar aplicar timeout em acesso já encerrado" do
      estudante = Estudante.create!(nome: "Ana", matricula: "242000444", grupo: "Grupo II", saldo: 0.00)
      acesso_negado = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")

      post timeout_terminal_path(acesso_negado), params: { catraca_id: catraca.id }

      expect(flash[:alert]).to eq("Catraca não está aguardando giro.")
    end
  end
end
