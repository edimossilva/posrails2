class Person < ApplicationRecord
	validates :name, presence: true
	#validates :last_name, presense: true
end
