require 'rails_helper'

RSpec.describe Api::V1::PeopleController, type: :controller do
    describe '#show' do
        let!(:person) { create :person, :with_image }
        context 'When person exists' do
            before do
                get :show, params: { id: person.id }
            end
            it 'responds :ok' do
                expect(response).to have_http_status(:ok)
            end
            it 'contains the person' do
                expected_person_json = PersonSerializer.new(person).to_json
                expect(response.body).to eq(expected_person_json)
            end
        end

        context 'When person does not exist' do
            before do
                get :show, params: { id: -1 }
            end
            it 'responds :not_found' do
                expect(response).to have_http_status(:not_found)
            end
            it 'contains not_found message' do
                expect(response.body).to include("not found")
            end
        end
    end

    describe '#index' do
        let!(:person) { create :person, :with_image }
        before do
        get :index
        end
        it 'responds :ok' do
        expect(response).to have_http_status(:ok)
        end
        it 'contains all people' do
        people = ActiveModel::SerializableResource.new(
            Person.all,
            each_serializer: PersonSerializer
        ).to_json
        expect(response.body).to eq(people)
        end
    end

    describe '#create' do
        let!(:name) { 'name qualquer' }
        let!(:last_name) { 'last_name qualquer' }
        let!(:image_name) { 'naruto.jpeg' }
        let!(:file_path) { Rails.root.join('spec', 'support', 'assets', image_name) }
        let!(:valid_image) { fixture_file_upload(file_path, 'image/jpeg') }

        context 'When image is created' do
            before do
                post :create, params: { name: name, last_name: last_name,image: valid_image }
            end
            it 'returns :created' do
                expect(response).to have_http_status(:created)
            end
            it 'contains field id' do
                body = response.body
                expect(JSON(body)['id']).to_not be_nil
            end

            it 'contains field name' do
                body = response.body
                #binding.pry
                expect(JSON(body)['nome_completo']).to include(name)
            end
            it 'contains field last_name' do
                body = response.body
                expect(JSON(body)['nome_completo']).to include(last_name)
            end
            it 'contains field image_url' do
                body = response.body
                body_image_name = JSON(body)['image_url'].split('/').last
                expect(body_image_name).to eq(image_name)
            end
        end





        context 'When image is not create' do

            #name  
            context 'When name is empty' do
                let!(:empty_name) { '' }
                let!(:last_name) { 'soares' }

                before do
                    post :create, params: { name: empty_name, last_name: last_name, image: valid_image }
                end
                it 'returns :unprocessable_entity' do
                expect(response).to have_http_status(:unprocessable_entity)
                end
                it 'contains name cant be blank error message' do
                body = response.body
                name_errors = JSON(body)['errors']['name']#nao sei se e name mesmo ou name
                expect(name_errors).to include("can't be blank")
                end
            end

        context 'When name has been taken' do
            let!(:person) { create :person, :with_image }
            let!(:taken_name) { person.name }
            let!(:last_name) { person.last_name }

            #nao sei se coloca o last_name tambem

            before do
                post :create, params: { name: taken_name, last_name: last_name,image: valid_image }
            end
            it 'returns :unprocessable_entity' do
                expect(response).to have_http_status(:unprocessable_entity)
            end
            it 'contains name has already been taken error message' do
                body = response.body
                name_errors = JSON(body)['errors']['name']#nao sei se e name mesmo ou name
                expect(name_errors).to include('has already been taken')
            end
        end
      
    end
  end

    describe '#destroy' do
        let!(:person) { create :person, :with_image }
        context 'When person exists' do
            before do
                get :destroy, params: { id: person.id }
            end
            it 'responds :ok' do
                #binding.pry
                expect(response).to have_http_status(:ok)
            end
            it 'contains the person' do
                expected_person_json = PersonSerializer.new(person).to_json
                expect(response.body).to eq(expected_person_json)
            end
        end

        context 'When person does not exist' do
            before do
                get :show, params: { id: -1 }
            end
            it 'responds :not_found' do
                expect(response).to have_http_status(:not_found)
            end
            it 'contains not_found message' do
                expect(response.body).to include("not found")
            end
        end
    end

end
