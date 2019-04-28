class PersonSerializer < ActiveModel::Serializer
    attributes :id, :nome_completo, :image_url
  
    def image_url
      self.object.image_url
    end

    def nome_completo
        "#{self.object.name}  #{self.object.last_name}"
    end
  end
  