class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :lastname, :full_name, :photo_url

   def full_name
   	#self.object.name
    "#{self.object.name} #{self.object.lastname}"
  	end

  def photo_url
    self.object.photo_url
  end
end
