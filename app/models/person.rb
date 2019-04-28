include Rails.application.routes.url_helpers
class Person < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :lastname, presence: true
  has_one_attached :image
  
  def full_name
    "#{self.name} #{self.lastname}"
  end
  
  def image_url
    url_for(image)
  end

end
