include Rails.application.routes.url_helpers
class Pessoa < ApplicationRecord
  validates :nome, presence: true, uniqueness: true
  validates :sobrenome, presence: true
  has_one_attached :foto

  def url_da_foto
    url_for(foto)
  end

  def nome_completo
    "#{self.nome} #{self.sobrenome}"
  end
end
