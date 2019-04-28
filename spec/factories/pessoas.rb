FactoryBot.define do
  factory :pessoa do
    nome { "some nome" }
    sobrenome { "some sobrenome" }
    trait :with_image do
      after :create do |pessoa|
        file_path = Rails.root.join('spec', 'support', 'assets', 'naruto.jpeg')
        file = fixture_file_upload(file_path, 'image/jpeg')
        pessoa.image.attach(file)
      end
    end
  end
end
