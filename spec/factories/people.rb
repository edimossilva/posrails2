include ActionDispatch::TestProcess
FactoryBot.define do
 factory :person do
   name { "naruto" }
   lastname { "uzumaki" }
   trait :with_photo do
     after :create do |person|
       file_path = Rails.root.join('spec', 'support', 'assets', 'naruto.jpeg')
       file = fixture_file_upload(file_path, 'image/jpeg')
       person.photo.attach(file)
     end
   end
 end
end
