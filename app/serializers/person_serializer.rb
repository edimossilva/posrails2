class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_name, :image_url

  def image_url
    self.object.image_url
  end
end