include Rails.application.routes.url_helpers
class Person < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :lastname, presence: true
  has_one_attached :photo

  def photo_url
    url_for(photo)
  end
end
