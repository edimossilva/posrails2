class Api::V1::PersonsController < ApplicationController

  before_action :create_service, :find_person, only: [:create, :index, :destroy]
  def show
    person = Person.find_by_id update_person_params[:id]

    if person
     render_person(person, :ok)
    else
      render_person_not_found
    end
  end

  def create
    person = @person_service.create create_person_params
    if person.valid?
      render_person(person, :created)
    else
      render_person_unprocessable_entity(person)
    end
  end

  def index
    render json: @person_service.all, each_serializer: PersonSerializer
  end

  def update
    person = Person.find_by_id update_person_params[:id]
    if person
      person.photo.attach update_person_params[:photo] if update_person_params[:photo]
      person.name = update_person_params[:name]
      if person.save
        render_person(person, :ok)
      else
        render_person_unprocessable_entity(person)
      end
    else
      render_person_not_found
    end
  end

  def destroy
        if @person.nil?
            render json: {message: "Product not found"}, status: :not_found
        else
            @person.destroy
        end
  end 

  private

  def find_person
    @person = Person.find_by_id(params[:id])
  end

  def create_person_params
    params.permit(:name, :lastname, :photo)
  end

  def update_person_params
    params.permit(:id, :name, :lastname, :photo)
  end

  def render_person(person, status)
    render json: person, status: status, serializer: PersonSerializer
  end

  def render_person_not_found
    render json: { message: 'not found'}, status: :not_found
  end

  def render_person_unprocessable_entity(person)
    render json: { errors: person.errors }, status: :unprocessable_entity
  end

  def create_service
    @person_service = PersonService.new
  end
end
