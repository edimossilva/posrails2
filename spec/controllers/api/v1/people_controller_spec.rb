require 'rails_helper'

RSpec.describe Api::V1::PeopleController, type: :controller do

  describe '#show' do
    let!(:person) { create :person, :with_image }
    context 'When picture exists' do
      before do
        get :show, params: { id: person.id }
      end
      it 'responds :ok' do
        expect(response).to have_http_status(:ok)    
      end
      it 'contains the photo' do
        expected_photo_json = PersonSerializer.new(person).to_json
        expect(response.body).to eq(expected_photo_json)
      end
    end
  end
end
