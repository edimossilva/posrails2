class Api::V1::PessoasController < ApplicationController

	before_action :create_service, only: [:create, :index]

	def show
	    people = Pessoa.find_by_id update_people_params[:id]

	    if people
	      render_people(people, :ok)
	    else
	      render_people_not_found
	    end
	end

	def index
		render json: @people_service.all, each_serializer: PessoaSerializer
	end

	def create
		people = @people_service.create create_people_params
		if people.valid?
			render_people(people, :created)
		else
			render_people_unprocessable_entity(people)
		end
	end

	def update
    	pessoa = Pessoa.find_by_id update_people_params[:id]
	    if pessoa
			if pessoa.update update_people_params
				render_people(pessoa, :ok)
			else
				render_people_unprocessable_entity(pessoa)
			end
		else
			render_people_not_found
	    end
	end

	def destroy
		people = Pessoa.find_by_id update_people_params[:id]
		if people
			people
		else
			render_people_not_found
		end
	end

	private

	def create_people_params
		params.permit(:nome, :sobrenome, :image)
	end

	def update_people_params
		params.permit(:id, :nome, :sobrenome, :image)
	end

	def render_people(pessoa, status)
		render json: pessoa, status: status, serializer: PessoaSerializer
	end

	def render_people_not_found
		render json: { message: 'not found'}, status: :not_found
	end

	def render_people_unprocessable_entity(pessoa)
		render json: { errors: pessoa.errors }, status: :unprocessable_entity
	end

	def create_service
		@people_service = PeopleService.new
	end

end
