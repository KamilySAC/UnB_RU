class RestaurantesController < ApplicationController
  def index
    @restaurantes = Restaurante.includes(:catracas).order(:nome)
  end

  def new
    @restaurante = Restaurante.new
  end

  def create
    @restaurante = Restaurante.new(restaurante_params)
    if @restaurante.save
      redirect_to restaurantes_path, notice: "Restaurante cadastrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @restaurante = Restaurante.find(params[:id])
  end

  def update
    @restaurante = Restaurante.find(params[:id])
    if @restaurante.update(restaurante_params)
      redirect_to restaurantes_path, notice: "Restaurante atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    restaurante = Restaurante.find(params[:id])
    if restaurante.destroy
      redirect_to restaurantes_path, notice: "Restaurante removido."
    else
      redirect_to restaurantes_path, alert: restaurante.errors.full_messages.to_sentence
    end
  end

  private

  def restaurante_params
    params.require(:restaurante)
          .permit(:codigo, :nome, :campus, :capacidade_por_hora, :total_pisos)
  end
end
