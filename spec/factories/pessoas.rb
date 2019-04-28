include ActionDispatch::TestProcess
FactoryBot.define do
  factory :pessoa do
    nome { "Josmadelmo" }
    sobrenome { "Davi" }
    trait :with_image do
      after :create do |pessoa|
        file_path = Rails.root.join('spec', 'support', 'assets', 'josmadelmodavi.jpg')
        file = fixture_file_upload(file_path, 'image/jpeg')
        pessoa.foto.attach(file)
      end
    end
  end
end
