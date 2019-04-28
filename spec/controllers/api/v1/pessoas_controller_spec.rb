require 'rails_helper'

RSpec.describe Api::V1::PessoasController, type: :controller do

	describe '#show' do
	    let!(:pessoa) { create :pessoa, :with_image }
	    context 'When people exists' do
			before do
				get :show, params: { id: pessoa.id }
			end
			it 'responds :ok' do
				expect(response).to have_http_status(:ok)
			end
	      	it 'contains the people' do
	        	expected_pessoa_json = PessoaSerializer.new(pessoa).to_json
	        	expect(response.body).to eq(expected_pessoa_json)
			end
	    end
	    context 'When people does not exist' do
			before do
				get :show, params: { id: -1 }
			end
			it 'responds :not_found' do
				expect(response).to have_http_status(:not_found)
			end
			it 'contains not_found message' do
				message = JSON(response.body)['message']
				expect(message).to eq("not found")
			end
	    end
 	end

	describe '#index' do
	    let!(:pessoa) { create :pessoa, :with_image }
	    before do
	      get :index
	    end
	    it 'responds :ok' do
	      expect(response).to have_http_status(:ok)
	    end
	    it 'contains all peoples' do
	      peoples = ActiveModel::SerializableResource.new(
	        Pessoa.all,
	        each_serializer: PessoaSerializer
	      ).to_json
	      expect(response.body).to eq(peoples)
	    end
	end

	describe '#create' do
	    let!(:name) { 'nome qualquer' }
	    let!(:sobrenome) { 'sobrenome qualquer' }
	    let!(:image_name) { 'naruto.jpeg' }
	    let!(:file_path) { Rails.root.join('spec', 'support', 'assets', image_name) }
	    let!(:valid_image) { fixture_file_upload(file_path, 'image/jpeg') }

	    context 'When image is created' do
			before do
				post :create, params: { nome: name, sobrenome: sobrenome, image: valid_image }
			end
			it 'returns :created' do
				expect(response).to have_http_status(:created)
			end
			it 'contains field full_name' do
				body = response.body
				expect(JSON(body)['full_name']).to eq(name + " " + sobrenome)
			end
			it 'contains field photo_url' do
				body = response.body
				body_image_name = JSON(body)['photo_url'].split('/').last
				expect(body_image_name).to eq(image_name)
			end
		end

		context 'When people is not create' do
			context 'When name is empty' do
				let!(:empty_name) { '' }
				before do
					post :create, params: { nome: empty_name, sobrenome: sobrenome, image: valid_image }
				end
				it 'returns :unprocessable_entity' do
					expect(response).to have_http_status(:unprocessable_entity)
				end
			end
			context 'When lastname is empty' do
				let!(:empty_lastname) { '' }
				before do
					post :create, params: { nome: name, sobrenome: empty_lastname, image: valid_image }
				end
				it 'returns :created' do
					expect(response).to have_http_status(:created)
				end
			end
			context 'When name has been taken' do
				let!(:pessoa) { create :pessoa, :with_image }
				let!(:taken_name) { pessoa.nome }
				let!(:taken_sobrenome) { pessoa.sobrenome }

				before do
					post :create, params: { nome: taken_name, sobrenome: taken_sobrenome,image: valid_image }
				end
				it 'returns :unprocessable_entity' do
					expect(response).to have_http_status(:unprocessable_entity)
				end
				it 'contains name has already been taken error message' do
					body = response.body
					name_errors = JSON(body)['errors']['nome']
					expect(name_errors).to include('has already been taken')
				end
			end
	    end
	end

	describe '#destroy' do
	    let!(:pessoa) { create :pessoa, :with_image }

	    context 'When delete the people' do
		    before do
				delete :destroy, params: { id: pessoa.id }
		    end
		    it 'responds :no_content' do
		      	expect(response).to have_http_status(:no_content)
		    end
		end
	    context 'When people does not exist' do
			before do
				delete :destroy, params: { id: -1 }
		    end
			it 'responds :not_found' do
				expect(response).to have_http_status(:not_found)
			end
			it 'contains not_found message' do
				message = JSON(response.body)['message']
				expect(message).to eq("not found")
			end
	    end
	end

	describe '#update' do
	    let!(:pessoa) { create :pessoa, :with_image }
 		let!(:update_name) { 'nome qualquer' }
	    let!(:update_sobrenome) { 'sobrenome qualquer' }
	    let!(:image_name) { 'naruto.jpeg' }
	    let!(:file_path) { Rails.root.join('spec', 'support', 'assets', image_name) }
	    let!(:update_image) { fixture_file_upload(file_path, 'image/jpeg') }

	    context 'When update the people' do
		    before do
				put :update, params: { id: pessoa.id, nome: update_name, sobrenome: update_sobrenome, image: update_image }
		    end
		    it 'responds :ok' do
		      	expect(response).to have_http_status(:ok)
		    end
		    it 'verify if change the full_name' do
		    	new_name = JSON(response.body)['full_name']
				expect(new_name).should_not eq(pessoa.nome + " " + pessoa.sobrenome)
		    end
		    it 'verify if change the field photo_url' do
		    	new_photo = JSON(response.body)['photo_url']
				expect(new_photo).should_not eq(pessoa.image_url)
		    end
		end

		context 'When the people new name exist' do
		    before do
				put :update, params: { id: pessoa.id, nome: update_name, sobrenome: update_sobrenome, image: update_image }
		    end
		    it 'responds :ok' do
		      	expect(response).to have_http_status(:ok)
		    end
		end

	    context 'When people does not exist' do
			before do
				put :update, params: { id: -1 }
		    end
			it 'responds :not_found' do
				expect(response).to have_http_status(:not_found)
			end
			it 'contains not_found message' do
				message = JSON(response.body)['message']
				expect(message).to eq("not found")
			end
	    end
	end

end
