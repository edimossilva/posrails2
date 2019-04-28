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
        let!(:nome) { 'nome qualquer' }
        let!(:sobrenome) { 'sobrenome qualquer' }
        let!(:image_name) { 'naruto.jpeg' }
        let!(:file_path) { Rails.root.join('spec', 'support', 'assets', image_name) }
        let!(:valid_image) { fixture_file_upload(file_path, 'image/jpeg') }

        context 'When image is created' do
            before do
                post :create, params: { nome: nome, sobrenome: sobrenome,image: valid_image }
            end
            it 'returns :created' do
                expect(response).to have_http_status(:created)
            end
            it 'contains field id' do
                body = response.body
                expect(JSON(body)['id']).to_not be_nil
            end
            it 'contains field nome' do
                body = response.body
                expect(JSON(body)['nome']).to eq(nome)
            end
            it 'contains field sobrenome' do
                body = response.body
                expect(JSON(body)['sobrenome']).to eq(sobrenome)
            end
            it 'contains field image_url' do
                body = response.body
                body_image_name = JSON(body)['image_url'].split('/').last
                expect(body_image_name).to eq(image_name)
            end
        end





        context 'When image is not create' do

            #nome  
            context 'When nome is empty' do
                let!(:empty_nome) { '' }
                let!(:sobrenome) { 'soares' }

                before do
                post :create, params: { nome: empty_nome, sobrenome: sobrenome, image: valid_image }
                end
                it 'returns :unprocessable_entity' do
                expect(response).to have_http_status(:unprocessable_entity)
                end
                it 'contains nome cant be blank error message' do
                body = response.body
                name_errors = JSON(body)['errors']['name']#nao sei se e name mesmo ou nome
                expect(name_errors).to include("can't be blank")
                end
            end

        context 'When nome has been taken' do
            let!(:person) { create :person, :with_image }
            let!(:taken_nome) { person.nome }
            #nao sei se coloca o sobrenome tambem

            before do
            post :create, params: { nome: taken_nome, image: valid_image }
            end
            it 'returns :unprocessable_entity' do
                expect(response).to have_http_status(:unprocessable_entity)
            end
            it 'contains nome has already been taken error message' do
                body = response.body
                name_errors = JSON(body)['errors']['name']#nao sei se e name mesmo ou nome
                expect(name_errors).to include('has already been taken')
            end
        end


        #sobrenome
        context 'When sobrenome is empty' do
            let!(:nome) { 'neylanio' }
            let!(:empty_sobrenome) { '' }

            before do
                post :create, params: { nome: nome, sobrenome: empty_sobrenome, image: valid_image }
            end
            it 'returns :unprocessable_entity' do
                expect(response).to have_http_status(:unprocessable_entity)
            end
            it 'contains nome cant be blank error message' do
                body = response.body
                name_errors = JSON(body)['errors']['name']#nao sei se e name mesmo ou sobrenome
                expect(name_errors).to include("can't be blank")
            end
        end

        context 'When sobrenome has been taken' do
            let!(:person) { create :person, :with_image }
            let!(:taken_sobrenome) { person.sobrenome }
            #nao sei se coloca o nome tambem

            before do
                post :create, params: { sobrenome: taken_sobrenome, image: valid_image }
            end
            it 'returns :unprocessable_entity' do
                expect(response).to have_http_status(:unprocessable_entity)
            end
            it 'contains sobrenome has already been taken error message' do
                body = response.body
                name_errors = JSON(body)['errors']['name']#nao sei se e name mesmo ou sobrenome
                expect(name_errors).to include('has already been taken')
            end
        end

      
    end
  end
end
