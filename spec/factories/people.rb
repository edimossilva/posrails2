FactoryBot.define do
  factory :person do

    name { "simples2" }
    last_name { "some name2" }
    trait :with_image do
      after :create do |person|
        file_path = Rails.root.join('spec', 'support', 'assets', 'naruto.jpeg')
        file = fixture_file_upload(file_path, 'image/jpeg')
        person.image.attach(file)
      end
    end

  end
end
