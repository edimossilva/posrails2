require 'rails_helper'

RSpec.describe Api::V1::PersonsController, type: :controller do
  let(:image_name) { 'naruto.jpeg' }
  let(:file) {
    fixture_file_upload(
      Rails.root.join('spec', 'support', 'assets', image_name),
      'image/jpeg'
    ) 
  }

  describe "#index" do
    before do
      get :index
    end

    it "responds ok" do
      expect(response).to have_http_status(:ok)
    end

    it "contains all persons" do
      persons = ActiveModelSerializers::SerializableResource.new(
        Person.all,
        each_serializer: PersonSerializer
      ).to_json
      expect(response.body).to eq(persons)
    end
  end
  
  describe '#create' do
    let(:person) { build :person, :with_image }

    context "When person was created" do
      before do
        post :create, params: { 
          name: person.name, 
          lastname: person.lastname,
          image: file
        }
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
        expect(JSON(body)['name']).to eq(person.name)
      end

      it 'contains field lastname' do
        body = response.body
        expect(JSON(body)['lastname']).to eq(person.lastname)
      end

      it 'contains field full_name' do
        body = response.body
        expect(JSON(body)['full_name']).to eq(person.full_name)
      end

      it 'contains field image_url' do
        body = response.body
        body_image_name = JSON(body)['image_url'].split('/').last
        expect(body_image_name).to eq(image_name)
      end
    end

    context 'When person is not create' do
      context 'When name is empty' do
        before do
          post :create, params: { 
            name: '', 
            lastname: person.lastname,
            image: file
          }
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

      context 'When lastname is empty' do
        before do
          post :create, params: { 
            name: person.name, 
            lastname: '',
            image: file
          }
        end

        it 'returns :unprocessable_entity' do 
          expect(response).to have_http_status(:unprocessable_entity)
        end
        
        it 'contains lastname cant be blank error message' do
          body = response.body
          lastname_errors = JSON(body)['errors']['lastname']
          expect(lastname_errors).to include("can't be blank")
        end
      end
    end

    context 'When name has been taken' do
      let(:person) { create :person, :with_image }
      before do
        post :create, params: { name: person.name, lastname: person.lastname, image: file }
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

  describe '#show' do
    let(:person) { create :person, :with_image }
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

  describe '#update' do
    let(:person) { create :person, :with_image }
    let(:person_imagem_name) { person.image_url.split('/').last }
    let(:file) {
      fixture_file_upload(
        Rails.root.join('spec', 'support', 'assets', "outro_#{person_imagem_name}"),
        'image/jpeg'
      ) 
    }
    context 'When person is successfully update' do
      before do
        put :update, params: {
          id: person.id,
          name: "#{person.name}s",
          lastname: "#{person.lastname}s",
          image: file
        }
      end

      it 'should responds with :ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'should not have the same name' do
        body = response.body
        name = JSON(body)['name']
        expect(name).not_to eq(person.name)
      end

      it 'should not have the same lastname' do
        body = response.body
        lastname = JSON(body)['lastname']
        expect(lastname).not_to eq(person.lastname)
      end

      it 'should not have the same full_name' do
        body = response.body
        full_name = JSON(body)['full_name']
        expect(full_name).not_to eq(person.full_name)
      end

      it 'should not have the same picture' do
        body = response.body
        body_image_name = JSON(body)['image_url'].split('/').last
        expect(body_image_name).not_to eq(person_imagem_name)
      end
    end

    context 'When person wasn\'t updated' do
      context 'When person wasn\'t found' do
        before do
          put :update, params: { id: -1 }
        end
        it 'responds :not_found' do
          expect(response).to have_http_status(:not_found)
        end
        it 'contains not_found message' do
          expect(response.body).to include("not found")
        end
      end

      context 'When name has already been taken' do
        let(:second_person) { create(:person, name: "Joe") }
        let(:person) { create :person, :with_image }
        
        before do
          put :update, params: {
            id: person.id,
            name: second_person.name,
            lastname: person.lastname,
            image: file
          }
        end

        it 'returns :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should has errors: name => has already been taken' do
          body = response.body
          name_errors = JSON(body)['errors']['name']
          expect(name_errors).to include('has already been taken')
        end
      end
    end
  end

  describe '#destroy' do
    let(:person) { create :person, :with_image }
    context 'When person exists' do
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
      it 'contains not_found message' do
        expect(response.body).to include("not found")
      end
    end
  end
end
