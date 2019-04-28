class Api::V1::PicturesController < ApplicationController

  before_action :create_service, only: [:create, :index]
  def show
    picture = Picture.find_by_id update_picture_params[:id]

    if picture
      render_picture(picture, :ok)
    else
      render_picture_not_found
    end
  end

  def create
    picture = @picture_service.create create_picture_params
    if picture.valid?
      render_picture(picture, :created)
    else
      render_picture_unprocessable_entity(picture)
    end
  end

  def index
    render json: @picture_service.all, each_serializer: PictureSerializer
  end

  def update
    picture = Picture.find_by_id update_picture_params[:id]
    if picture
      picture.image.attach update_picture_params[:image] if update_picture_params[:image]
      picture.name = update_picture_params[:name]
      if picture.save
        render_picture(picture, :ok)
      else
        render_picture_unprocessable_entity(picture)
      end
    else
      render_picture_not_found
    end
  end

  private

  def create_picture_params
    params.permit(:name, :image)
  end

  def update_picture_params
    params.permit(:id, :name, :image)
  end

  def render_picture(picture, status)
    render json: picture, status: status, serializer: PictureSerializer
  end

  def render_picture_not_found
    render json: { message: 'not found'}, status: :not_found
  end

  def render_picture_unprocessable_entity(picture)
    render json: { errors: picture.errors }, status: :unprocessable_entity
  end

  def create_service
    @picture_service = PictureService.new
  end
end
