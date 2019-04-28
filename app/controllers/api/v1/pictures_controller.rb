class Api::V1::PicturesController < ApplicationController
  def create
    picture = Picture.new create_picture_params
    picture.image.attach create_picture_params[:image] if create_picture_params[:image]
    if picture.save
      render_picture(picture, :created)
    else
      render json: { errors: picture.errors }, status: :unprocessable_entity
    end
  end

  def index
    render json: Picture.all , each_serializer: PictureSerializer
  end

  def update
    picture = Picture.find_by_id update_picture_params[:id]
    if picture
      picture.image.attach update_picture_params[:image] if update_picture_params[:image]
      picture.name = update_picture_params[:name]
      if picture.save
        render_picture(picture, :ok)
      else
        render json: { errors: picture.errors }, status: :unprocessable_entity
      end
    else
      render_picture_not_found
    end
  end

  def show
    picture = Picture.find_by_id params[:id]
    if picture
      render_picture(picture, :ok)
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
    render json: { message: "not found"}, status: :not_found
  end

end
