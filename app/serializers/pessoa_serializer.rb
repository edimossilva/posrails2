class PessoaSerializer < ActiveModel::Serializer
  attributes :full_name, :photo_url

  def photo_url
    self.object.image_url
  end

  def full_name
	self.object.nome + " " + self.object.sobrenome
  end
end
