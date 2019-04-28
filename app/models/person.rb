class Person < ApplicationRecord
	validates :name, presence: true, uniqueness: true 
	validates :lastname, presence: true, uniqueness: true 
end
