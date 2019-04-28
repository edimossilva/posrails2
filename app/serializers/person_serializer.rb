class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :lastname, :photo_url

  def photo_url
    self.object.photo_url
  end
end
