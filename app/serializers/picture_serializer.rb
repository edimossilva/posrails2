class PictureSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url

  def image_url
    self.object.image_url
  end
end
