class PersonSerializer < ActiveModel::Serializer
    attributes :id, :nome, :sobrenome,:image_url, :nome_completo
  
    def image_url
      self.object.image_url
    end

    def nome_completo
        self.object.nome = self.object.nome << self.object.sobrenome
    end
  end
  