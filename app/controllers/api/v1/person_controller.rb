class Api::V1::PersonController < ApplicationController
	before_action :create_service, only: [:create, :index]
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
      person.image.attach update_person_params[:image] if update_person_params[:image]
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

  private

  def create_person_params
    params.permit(:name, :image, :lastname)
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

  def create_service
    @person_service = PictureService.new
  end
end
