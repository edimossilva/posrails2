class Api::V1::PersonsController < ApplicationController
  before_action :find_person, only: [:update, :show, :destroy]
  def index
    render json: Person.all, each_serializer: PersonSerializer
  end

  def create
    person = Person.create create_person_params
    if person.valid?
      render_person(person, :created)
    else
      render_person_unprocessable_entity(person)
    end
  end

  def update
    if @person
      @person.image.attach update_person_params[:image] if update_person_params[:image]
      @person.name = update_person_params[:name]
      @person.lastname = update_person_params[:lastname]
      if @person.save
        render_person(@person, :ok)
      else
        render_person_unprocessable_entity(@person)
      end
    else
      render_person_not_found
    end
  end

  def show
    if @person
      render_person(@person, :ok)
    else
      render_person_not_found
    end
  end

  def destroy
    if @person
      @person.destroy
    else
      render_person_not_found
    end
  end

  private

  def find_person
    @person = Person.find_by_id(params[:id])
  end

  def create_person_params
    params.permit(:name, :lastname, :image)
  end

  def update_person_params
    params.permit(:id, :name, :lastname, :image)
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
end
