require 'rails_helper'

RSpec.describe Api::V1::PicturesController, type: :controller do
  describe '#show' do
    let!(:picture) { create :picture, :with_image }
    context 'When picture exists' do
      before do
        get :show, params: { id: picture.id }
      end
      it 'responds :ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'contains the picture' do
        expected_picture_json = PictureSerializer.new(picture).to_json
        expect(response.body).to eq(expected_picture_json)
      end
    end
    context 'When picture does not exist' do
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
    let!(:picture) { create :picture, :with_image }
    before do
      get :index
    end
    it 'responds :ok' do
      expect(response).to have_http_status(:ok)
    end
    it 'contains all pictures' do
      pictures = ActiveModel::SerializableResource.new(
        Picture.all,
        each_serializer: PictureSerializer
      ).to_json
      expect(response.body).to eq(pictures)
    end
  end

  describe '#create' do
    let!(:name) { 'nome qualquer' }
    let!(:image_name) { 'naruto.jpeg' }
    let!(:file_path) { Rails.root.join('spec', 'support', 'assets', image_name) }
    let!(:valid_image) { fixture_file_upload(file_path, 'image/jpeg') }

    context 'When image is created' do
      before do
        post :create, params: { name: name, image: valid_image }
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
      it 'contains field image_url' do
        body = response.body
        body_image_name = JSON(body)['image_url'].split('/').last
        expect(body_image_name).to eq(image_name)
      end
    end

    context 'When image is not create' do

      context 'When name is empty' do
        let!(:empty_name) { '' }
        before do
          post :create, params: { name: empty_name, image: valid_image }
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
        let!(:picture) { create :picture, :with_image }
        let!(:taken_name) { picture.name }

        before do
          post :create, params: { name: taken_name, image: valid_image }
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
