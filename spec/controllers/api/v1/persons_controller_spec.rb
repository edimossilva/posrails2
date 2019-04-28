require 'rails_helper'

RSpec.describe Api::V1::PersonsController, type: :controller do
  describe '#show' do
    let!(:person) { create :person, :with_photo }
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
    let!(:person) { create :person, :with_photo }
    before do
      get :index
    end
    it 'responds :ok' do
      expect(response).to have_http_status(:ok)
    end
    it 'contains all persons' do
      persons = ActiveModel::SerializableResource.new(
        Person.all,
        each_serializer: PersonSerializer
      ).to_json
      expect(response.body).to eq(persons)
    end
  end

 describe '#destroy' do
    let(:person) { create :person, :with_photo }
    context 'When person exist' do
      before do
        delete :destroy, params: { id: person.id }
      end
      it 'responds :no_content' do
        expect(response).to have_http_status(:no_content)
      end
      it 'person was destroyed' do
        expect(Person.find_by_id(person.id)).to be_nil
      end
    end
    context 'When person does not exist' do
      before do
        delete :destroy, params: { id: -1 }
      end
      it 'responds :not_found' do
        expect(response).to have_http_status(:not_found)
      end
      it 'contains not_found' do
        expect(response.body).to include("not found")
      end
    end
  end

 describe '#update' do
    let!(:person) { create :person, :with_photo }
    let!(:new_name) { 'naruto' }
    let!(:new_lastname) { 'pereira' }
    let!(:photo_name) { 'naruto.jpeg' }
    let!(:file_path) { Rails.root.join('spec', 'support', 'assets', photo_name) }
    let!(:new_photo) { fixture_file_upload(file_path, 'image/jpeg') }
    context 'When person is update' do  
      context 'When person name is update' do
          before do
            put :update, params: { id: person.id, name: new_name }
          end
          it 'returns :ok' do
            expect(response).to have_http_status(:ok)
          end
    end

    context 'When person lastname is update' do
          before do
            put :update, params: { id: person.id, name: new_lastname }
          end
          it 'returns :ok' do
            expect(response).to have_http_status(:ok)
          end
    end

    context 'When person photo is update' do
          before do
            put :update, params: { id: person.id, name: new_photo }
          end
          it 'returns :ok' do
            expect(response).to have_http_status(:ok)
          end
    end

    end  
    context 'When person is not update' do 
      context 'When person is not found' do
        before do
            put :update, params: { id: -1, name: new_name }
          end
          it 'responds :not_found' do
            expect(response).to have_http_status(:not_found)
          end
        end
    end

  end 

  describe '#create' do
    let!(:name) { 'nome qualquer' }
    let!(:lastname) { 'sobrenome' }
    let!(:photo_name) { 'naruto.jpeg' }
    let!(:file_path) { Rails.root.join('spec', 'support', 'assets', photo_name) }
    let!(:valid_photo) { fixture_file_upload(file_path, 'image/jpeg') }
    context 'When person is created' do  

      before do
        post :create, params: { name: name, lastname: lastname, photo: valid_photo }
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
        expect(JSON(body)['name']).to eq(name)
      end
      it 'contains field lastname' do
        body = response.body
        expect(JSON(body)['lastname']).to eq(lastname)
      end
      it 'contains field photo_url' do
        body = response.body
        body_photo_name = JSON(body)['photo_url'].split('/').last
        expect(body_photo_name).to eq(photo_name)
      end
    end
    context 'When person is not create' do
      context 'When name is empty' do
        let!(:empty_name) { '' }
        before do
          post :create, params: { name: empty_name, lastname: lastname, photo: valid_photo }
        end
        it 'returns :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'contains name cant be blank error message' do
          body = response.body
          name_errors = JSON(body)['errors']['name']
          expect(name_errors).to include("can't be blank")
        end
      end
      context 'When name has been taken' do
        let!(:person) { create :person, :with_photo }
        let!(:taken_name) { 'naruto' }
       
        before do
          #binding.pry
          post :create, params: { name: taken_name, lastname: lastname, photo: valid_photo }
        end
        it 'returns :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'contains name has already been taken error message' do
          body = response.body
          name_errors = JSON(body)['errors']['name']
          expect(name_errors).to include('has already been taken')
        end
      end
    end
  end
end
