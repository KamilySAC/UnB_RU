# Passos da feature "Visualizar cardápio da refeição atual" (features/visualizar_cardapio.feature).
# O relógio é congelado numa segunda-feira, às 12h (almoço), e o cardapio.json é trocado por um arquivo
# de teste em tmp/, para os cenários não dependerem do dia em que são executados.

World(ActiveSupport::Testing::TimeHelpers)

module CardapioHelpers
  ARQUIVO_TESTE = Rails.root.join("tmp", "cardapio_cucumber.json")

  CARDAPIO_SEGUNDA = {
    "segunda-feira" => {
      "almoco" => {
        "salada_1" => "Alface lisa com agrião",
        "salada_2" => "Tomate",
        "prato_principal_padrao" => "Frango assado com manjericão",
        "prato_principal_ovolactovegetariano" => "Quiche de legumes e lentilha gratinada",
        "prato_principal_vegetariano_estrito" => "Refogado de lentilha, couve-flor e brócolis",
        "guarnicao" => "Jardineira verde (Chuchu e abobrinha)",
        "acompanhamentos" => [ "Arroz branco e integral", "Feijão preto" ],
        "sobremesa" => "Mix de doces",
        "bebida" => "Refresco de morango"
      }
    }
  }.freeze

  def usar_cardapio(conteudo)
    File.write(ARQUIVO_TESTE, conteudo.to_json)
    CardapioAtual.arquivo = ARQUIVO_TESTE
    Restaurante.create!(codigo: "RU-DR", nome: "RU Darcy Ribeiro", total_pisos: 1)
    # segunda-feira, 16/11/2026, 12h em Brasília (horário do almoço)
    travel_to Time.find_zone!("Brasilia").local(2026, 11, 16, 12, 0)
  end
end
World(CardapioHelpers)

After do
  travel_back
  CardapioAtual.arquivo = nil
  FileUtils.rm_f(CardapioHelpers::ARQUIVO_TESTE)
end


# bloco 1: dado

Dado("que estou logado na plataforma") do
  @estudante = Estudante.create!(
    nome: "Ana Sarah Nagata",
    matricula: "250000010",
    password: "senha123"
  )
  page.driver.post login_path, matricula: @estudante.matricula, senha: "senha123"
end

Dado("existe um cardápio cadastrado para a refeição atual") do
  usar_cardapio(CardapioHelpers::CARDAPIO_SEGUNDA)
end

Dado("não existe cardápio cadastrado para a refeição atual") do
  usar_cardapio({})
end


# bloco 2: quando

Quando("acesso a página inicial") do
  visit root_path
end


# bloco 3: então

Então("devo visualizar o nome do restaurante e seu horário de funcionamento") do
  within("#cardapio") do
    expect(page).to have_content("RU Darcy Ribeiro")
    expect(page).to have_content("11:00 às 14:30")
  end
end

Então("devo visualizar as opções de cardápio padrão, ovolactovegetariano e vegetariano estrito na seção de cardápio") do
  within("#cardapio") do
    expect(page).to have_css(".opcao-cardapio", count: 3)
    expect(page).to have_content("Padrão")
    expect(page).to have_content("Ovolactovegetariano")
    expect(page).to have_content("Vegetariano estrito")
  end
end

Então("cada opção deve apresentar prato principal, guarnição, salada, sobremesa e bebida") do
  opcoes = all("#cardapio .opcao-cardapio")
  expect(opcoes.size).to eq(3)

  opcoes.each do |opcao|
    [ "Prato principal", "Guarnição", "Salada", "Sobremesa", "Bebida" ].each do |item|
      expect(opcao).to have_content(item)
    end
  end

  within("#cardapio") do
    expect(page).to have_content("Frango assado com manjericão")
    expect(page).to have_content("Quiche de legumes e lentilha gratinada")
    expect(page).to have_content("Refogado de lentilha, couve-flor e brócolis")
  end
end

Então("a seção de cardápio deve apresentar uma mensagem informando a indisponibilidade de cardápio") do
  within("#cardapio") do
    expect(page).to have_content(CardapioAtual::MSG_INDISPONIVEL)
    expect(page).to have_no_css(".opcao-cardapio")
  end
end