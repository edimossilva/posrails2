require 'rails_helper'

RSpec.describe Api::V1::PicturesController, type: :controller do
  describe "#index" do
    let!(:picture) { create :picture, :with_image }
    before do
      get :index
    end
    it "responds :ok" do
      expect(response).to have_http_status(:ok)
    end
    it "contains all pictures" do
      pictures = ActiveModelSerializers::SerializableResource.new(
        Picture.all,
        each_serializer: PictureSerializer
      ).to_json
      expect(response.body).to eq(pictures)
    end
  end

  describe "#create" do
    let!(:name) { 'Name' }
    let(:image_name) { 'naruto.jpeg' } 
    let!(:file_path) { Rails.root.join('spec', 'support', 'assets', image_name) }
    let!(:image) { fixture_file_upload(file_path, 'image/jpeg') }
    
    before do
      post :create, params: { name: name, image: image }
    end

    context 'When image is created' do
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

    context 'When image is not created' do
      
    end
  end

  describe "#show" do
    let!(:picture) { create :picture, :with_image }

    context 'When picture exists' do
      before do
        get :show, params: {id: picture.id}
      end
      it "responds :ok" do
        expect(response).to have_http_status(:ok)
      end
  
      it "should contains the picture" do
        expected_picture_json = PictureSerializer.new(picture).to_json
        expect(response.body).to eq(expected_picture_json)
      end
    end

    context 'When picture does not exists' do
      before do
        get :show, params: {id: 0}
      end
      it "responds :not_found" do
        expect(response).to have_http_status(:not_found)
      end

      it "contains not_found message" do
        expect(response.body).to include('not found')
      end
    end
  end
end
