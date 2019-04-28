class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :lastname, :full_name, :image_url

  def full_name
    "#{self.object.name} #{self.object.lastname}"
  end
  
  def image_url
    self.object.image_url
  end
end
