include Rails.application.routes.url_helpers
class Person < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :last_name, presence: true
    has_one_attached :image
  
    def image_url
      url_for(image)
    end
end
