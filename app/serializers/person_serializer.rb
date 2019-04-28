class PersonSerializer < ActiveModel::Serializer
    attributes :id, :nome_completo, :url
  
    def nome_completo
      "#{self.object.name} #{self.object.surname}" 
    end

    def url
      self.object.photo_url
    end
  end
  