require 'rails_helper'

RSpec.describe Api::V1::PersonsController, type: :controller do
	describe "#index" do
		before do
			get :index
		end
		it "response :ok" do
			expect(response).to have_http_status(:ok)
		end	
	end	
end
