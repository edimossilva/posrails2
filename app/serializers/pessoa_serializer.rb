class PessoaSerializer < ActiveModel::Serializer
  attributes :id, :nome, :sobrenome, :url_da_foto, :nome_completo

  def url_da_foto
    self.object.url_da_foto
  end

  def nome_completo
    "#{self.object.nome} #{self.object.sobrenome}"
  end
end
