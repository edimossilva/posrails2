include Rails.application.routes.url_helpers
class Pessoa < ApplicationRecord
	validates :nome, presence: true, uniqueness: true
	has_one_attached :image

	def image_url
		url_for(image)
	end
end
