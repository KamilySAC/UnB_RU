class CatracasController < ApplicationController
  def new
    @restaurante = Restaurante.find(params[:restaurante_id])
    @catraca = @restaurante.catracas.build
  end

  def create
    @restaurante = Restaurante.find(params[:restaurante_id])
    @catraca = @restaurante.catracas.build(catraca_params)
    if @catraca.save
      redirect_to restaurantes_path, notice: "Catraca cadastrada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @catraca = Catraca.find(params[:id])
  end

  def update
    @catraca = Catraca.find(params[:id])
    if @catraca.update(catraca_params)
      redirect_to restaurantes_path, notice: "Catraca atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    catraca = Catraca.find(params[:id])
    if catraca.destroy
      redirect_to restaurantes_path, notice: "Catraca removida."
    else
      redirect_to restaurantes_path, alert: catraca.errors.full_messages.to_sentence
    end
  end

  private

  def catraca_params
    params.require(:catraca).permit(:codigo, :nome, :piso, :status)
  end
end
