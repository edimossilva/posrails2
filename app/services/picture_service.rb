class PictureService
  def create(create_picture_params)
    Picture.create create_picture_params
  end

  def all
    Picture.all
  end
end
