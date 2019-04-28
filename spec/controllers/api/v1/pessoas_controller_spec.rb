require 'rails_helper'

RSpec.describe Api::V1::PessoasController, type: :controller do
  let!(:url_da_foto) { 'josmadelmodavi.jpg' }
  let!(:file_path) { Rails.root.join('spec', 'support', 'assets', url_da_foto) }
  let!(:valid_image) { fixture_file_upload(file_path, 'image/jpeg') }
  describe '#create' do
    let!(:nome) { 'Josmadelmo' }
    let!(:sobrenome) { 'Davi' }
    context 'Quando pessoa é criada' do
      before do
        post :create, params: { nome: nome, sobrenome: sobrenome, foto: valid_image }
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
      it 'contains field nome completo' do
        body = response.body
        expect(JSON(body)['nome_completo']).to eq("#{nome} #{sobrenome}")
      end
      it 'contains field sobrenome' do
      	body = response.body
      	expect(JSON(body)['sobrenome']).to eq(sobrenome)
      end
      it 'contains field url_da_foto' do
        body = response.body
        body_url_da_foto = JSON(body)['url_da_foto'].split('/').last
        expect(body_url_da_foto).to eq(url_da_foto)
      end
    end
    context 'Quando pessoa não é criada' do
      context 'Quando nome está vazio' do
        let!(:empty_nome) { '' }
        before do
          post :create, params: { nome: empty_nome, sobrenome: sobrenome, foto: valid_image }
        end
        it 'returns :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'contains nome cant be blank error message' do
          body = response.body
          nome_errors = JSON(body)['errors']['nome']
          expect(nome_errors).to include("can't be blank")
        end
      end
      context 'Quando sobrenome está vazio' do
        let!(:empty_sobrenome) { '' }
        before do
          post :create, params: { nome: nome, sobrenome: empty_sobrenome, foto: valid_image }
        end
        it 'returns :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'contains sobrenome cant be blank error message' do
          body = response.body
          sobrenome_errors = JSON(body)['errors']['sobrenome']
          expect(sobrenome_errors).to include("can't be blank")
        end
      end
      context 'Quando nome já existe' do
        let!(:pessoa) { create :pessoa, :with_image }
        let!(:taken_nome) { pessoa.nome }

        before do
          post :create, params: { nome: taken_nome, sobrenome: sobrenome, foto: valid_image }
        end
        it 'returns :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'contains nome has already been taken error message' do
          body = response.body
          nome_errors = JSON(body)['errors']['nome']
          expect(nome_errors).to include('has already been taken')
        end
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
    it 'contains all pessoas' do
      pessoas = ActiveModelSerializers::SerializableResource.new(
        Pessoa.all,
        each_serializer: PessoaSerializer
      ).to_json
      expect(response.body).to eq(pessoas)
    end
  end

  describe '#show' do
    let!(:pessoa) { create :pessoa, :with_image }
    context 'Quando pessoa existe' do
      before do
        get :show, params: { id: pessoa.id }
      end
      it 'responds :ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'contains the pessoa' do
        expected_picture_json = PessoaSerializer.new(pessoa).to_json
        expect(response.body).to eq(expected_picture_json)
      end
    end
    context 'Quando pessoa não existe' do
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
  	let!(:pessoa) { create :pessoa, :with_image }
    let!(:nome_novo) { 'Davi' }
    let!(:sobrenome_novo) { 'Josmadelmo' }
    let!(:url_da_foto) { 'leonardobrito.jpg' }
    let!(:file_path) { Rails.root.join('spec', 'support', 'assets', url_da_foto) }
    let!(:valid_image) { fixture_file_upload(file_path, 'image/jpeg') }
    context 'Quando pessoa existe' do
      before do
        put :update, params: { id: pessoa.id, nome: nome_novo, sobrenome: sobrenome_novo, foto: valid_image }
      end
      it 'responds :ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'nome should be different' do
      	expect(JSON(response.body)['nome']).to_not eq(pessoa.nome)
      end
      it 'sobrenome should be different' do
      	expect(JSON(response.body)['sobrenome']).to_not eq(pessoa.sobrenome)
      end
      it 'nome_completo should be different' do
      	expect(JSON(response.body)['nome_completo']).to_not eq(pessoa.nome_completo)
      end
      it 'url_da_foto should be different' do
      	url_da_foto_antiga = pessoa.url_da_foto.split('/').last
        body_url_da_foto = JSON(response.body)['url_da_foto'].split('/').last
        expect(body_url_da_foto).to_not eq(url_da_foto_antiga)
      end
    end
    context 'Quando pessoa não existe' do
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
  end

  describe '#destroy' do
    let!(:pessoa) { create :pessoa, :with_image }
    context 'Quando pessoa existe' do
      before do
      	delete :destroy, params: { id: pessoa.id }
      end
      it 'responds :no_content' do
        expect(response).to have_http_status(:no_content)
      end
      it 'not contains the pessoa' do
        expect(Pessoa.find_by_id(pessoa.id)).to be_nil
      end
    end
    context 'Quando pessoa não existe' do
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
# $ rspec -fd  spec/controllers/api/v1/pictures_controller_spec.rb