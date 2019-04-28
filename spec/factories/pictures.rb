include ActionDispatch::TestProcess
FactoryBot.define do
  factory :picture do
    name { "some name" }
    trait :with_image do
      after :create do |picture|
        file_path = Rails.root.join('spec', 'support', 'assets', 'naruto.jpeg')
        file = fixture_file_upload(file_path, 'image/jpeg')
        picture.image.attach(file)
      end
    end
  end
  #factory :person do
  #  name { "naruto" }
  #  lastname { "uzumaki" }
  #  trait :with_photo do
  #    after :create do |person|
  #      file_path = Rails.root.join('spec', 'support', 'assets', 'naruto.jpeg')
  #      file = fixture_file_upload(file_path, 'image/jpeg')
  #      person.photo.attach(file)
  #    end
  #  end
  #end
end
