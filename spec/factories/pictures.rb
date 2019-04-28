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
end
