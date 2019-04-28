include Rails.application.routes.url_helpers
class Person < ApplicationRecord
    validates :nome, presence: true, uniqueness: true
    validates :sobrenome, presence: true
    has_one_attached :image
  
    def image_url
      url_for(image)
    end
end
