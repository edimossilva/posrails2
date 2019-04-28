class Api::V1::PessoasController < ApplicationController
  before_action :create_service, only: [:create, :index]
  def show
    pessoa = Pessoa.find_by_id update_pessoa_params[:id]

    if pessoa
      render_pessoa(pessoa, :ok)
    else
      render_pessoa_not_found
    end
  end

  def create
    pessoa = @pessoa_service.create create_pessoa_params
    if pessoa.valid?
      render_pessoa(pessoa, :created)
    else
      render_pessoa_unprocessable_entity(pessoa)
    end
  end

  def index
    render json: @pessoa_service.all, each_serializer: PessoaSerializer
  end

  def update
    pessoa = Pessoa.find_by_id update_pessoa_params[:id]
    if pessoa
      pessoa.foto.attach update_pessoa_params[:foto] if update_pessoa_params[:foto]
      pessoa.nome = update_pessoa_params[:nome]
      if pessoa.save
        render_pessoa(pessoa, :ok)
      else
        render_pessoa_unprocessable_entity(pessoa)
      end
    else
      render_pessoa_not_found
    end
  end

  def destroy
  	pessoa = Pessoa.find_by_id params[:id]
	if pessoa.nil?
		render_pessoa_not_found
	else
		pessoa.destroy
	end
  end

  private

  def create_pessoa_params
    params.permit(:nome, :sobrenome, :foto)
  end

  def update_pessoa_params
    params.permit(:id, :nome, :sobrenome, :foto)
  end

  def render_pessoa(pessoa, status)
    render json: pessoa, status: status, serializer: PessoaSerializer
  end

  def render_pessoa_not_found
    render json: { message: 'not found'}, status: :not_found
  end

  def render_pessoa_unprocessable_entity(pessoa)
    render json: { errors: pessoa.errors }, status: :unprocessable_entity
  end

  def create_service
    @pessoa_service = PessoaService.new
  end
end
