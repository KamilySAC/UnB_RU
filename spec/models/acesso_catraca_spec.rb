# carrega configurações de teste do rails
require "rails_helper"

RSpec.describe "Acesso Catraca", type: :model do
  # Bloco 1 de testes: ler_identificacao
  describe ".ler_identificação" do
    # cenário: QR Code não existe no sistema
    it "bloqueia a catraca quando a matrícula não existe na base de dados" do
      acesso = AcessoCatraca.ler_identificacao(
        identificacao: "999999999",
        turno: "Almoço"
      )

      # verifica se travou a catraca e exibiu o aviso correto no visor
      expect(acesso.status_catraca).to eq("bloqueada")

      expect(acesso.status_acesso).to eq("negado")

      expect(acesso.mensagem_visor).to eq("Usuário não encontrado")

      expect(acesso.estudante).to be_nil
    end

    # cenário: tentativa de dupla refeição no mesmo turno
    it "bloqueia por anti-passback se o discente já realisou refeição no mesmo turno hoje" do
      # cria estudante no bando de dados
      estudante = Estudante.create!(
        nome: "Arthur",
        matricula: "242009990",
        grupo: "Grupo II",
        saldo: 20.00
      )

      # primeiro acesso do almoço: simulamos já concluído hoje
      primeiro_acesso = AcessoCatraca.ler_identificacao(
        identificacao: "242009990",
        turno: "Almoço"
      )
      primeiro_acesso.registrar_giro!

      # segundo acesso no mesmo turno, a catraca deve bloquear
      segundo_acesso = AcessoCatraca.ler_identificacao(
        identificacao: "242009990",
        turno: "Almoço"
      )

      expect(segundo_acesso.status_catraca).to eq("bloqueada")
      expect(segundo_acesso.status_acesso).to eq("negado")
      expect(segundo_acesso.mensagem_visor).to eq("Refeição já utilizada neste turno")
      expect(estudante.reload.saldo).to eq(15.50) # apenas o valor da primeira refeição foi descontado do saldo
    end


    # cenário saldo insuficiente
    it "libera a catraca para discente do grupo I mesmo com saldo de R$ 0.00" do
      estudante = Estudante.create!(nome: "Bolsista", matricula: "111111111", grupo: "Grupo I", saldo: 0.00)

      acesso =  AcessoCatraca.ler_identificacao(
        identificacao: "111111111",
        turno: "Almoço"
      )

      expect(acesso.status_catraca).to eq("liberada")
      expect(acesso.status_acesso).to eq("aguardando_giro")
      expect(acesso.isento).to be true
      expect(acesso.valor_debitado).to eq(0.00)
    end


    # cenário feliz, pagante com saldo suficiente
    it "bloqueia quando discente pagante não possui saldo suficiente para o turno" do
        # almoço do Grupo II custa R$ 4,50; discente tem apenas R$ 4,49
        estudante = Estudante.create!(
          nome: "Arthur",
          matricula: "242009990",
          grupo: "Grupo II",
          saldo: 4.49
        )

        acesso = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")

        expect(acesso.status_catraca).to eq("bloqueada")
        expect(acesso.status_acesso).to eq("negado")
        expect(acesso.mensagem_visor).to eq("Saldo insuficiente")

        # Saldo permanece intacto
        expect(estudante.reload.saldo).to eq(4.49)
      end



      # cenário de isenção (Grupo I com saldo zero)
      it "libera a catraca para discente do Grupo I mesmo com saldo de R$ 0,00" do
        estudante = Estudante.create!(
          nome: "Bolsista",
          matricula: "111111111",
          grupo: "Grupo I",
          saldo: 0.00
        )

        acesso = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")

        expect(acesso.status_catraca).to eq("liberada")
        expect(acesso.status_acesso).to eq("aguardando_giro")
        expect(acesso.isento).to be true
        expect(acesso.valor_debitado).to eq(0.00)
      end


      # cenário: Caminho Feliz - Pagante com saldo suficiente
      it "libera a catraca aguardando giro e não debita o saldo antes da passagem física" do
        estudante = Estudante.create!(
          nome: "Arthur",
          matricula: "242009990",
          grupo: "Grupo II",
          saldo: 10.00
        )

        acesso = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")

        expect(acesso.status_catraca).to eq("liberada")
        expect(acesso.status_acesso).to eq("aguardando_giro")
        expect(acesso.mensagem_visor).to eq("Catraca liberada")

        # Saldo continua R$ 10,00 até que ocorra o giro físico!
        expect(estudante.reload.saldo).to eq(10.00)
      end
    end


    # bloco 2 - testes da função: registrar_giro!
    describe "#registrar_giro!" do
      it "debita a tarifa correspondente e registra o acesso quando o discente gira a catraca" do
        # almoço do grupo II custa R$ 4,50; saldo inicial = 10, salfo final = 5.50
        estudante = Estudante.create!(
          nome: "Arthur",
          matricula: "242009990",
          grupo: "Grupo II",
          saldo: 10.00
        )

        acesso = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")

        # Dispara o giro físico da catraca
        acesso.registrar_giro!
        expect(estudante.reload.saldo).to eq(5.50)
        expect(acesso.reload.status_acesso).to eq("registrado")
      end

      it "não efetua débito ao registrar giro de discente isento (Grupo I)" do
        estudante = Estudante.create!(
          nome: "Bolsista",
          matricula: "111111111",
          grupo: "Grupo I",
          saldo: 0.00
        )

        acesso = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")
        acesso.registrar_giro!

        expect(estudante.reload.saldo).to eq(0.00)
        expect(acesso.reload.status_acesso).to eq("isento")
      end
    end

    # bloco 3 - testes da função: verificar_timeout!
    describe "#verificar_timeout!" do
      it "bloqueia a catraca, cancela o acesso e mantém o saldo quando passam-se 5 segundos sem giro" do
        estudante = Estudante.create!(
          nome: "Arthur",
          matricula: "242009990",
          grupo: "Grupo II",
          saldo: 10.00
        )
        acesso = AcessoCatraca.ler_identificacao(identificacao: estudante.matricula, turno: "Almoço")

        timeout_acionado = acesso.verificar_timeout!(5)

        expect(timeout_acionado).to be true
        expect(acesso.reload.status_catraca).to eq("bloqueada")
        expect(acesso.status_acesso).to eq("cancelado")
        expect(estudante.reload.saldo).to eq(10.00)
      end
    end
  end
