require 'rails_helper'

describe UsersController do
  let(:user) { mock_model(User) }
  let(:company) { mock_model(Company) }
  let(:current_user) { mock_model(User) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#new' do
    def send_request
      get :new
    end
  end

  describe '#show' do
    before do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:account_owner?).and_return(true)
      allow(controller).to receive(:authenticate_user!)
    end

    def send_request
      get :show, { user: { name: 'Test User' }, id: user.id }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(User).to receive(:find).and_return(user) }
      it { expect(controller).to receive(:authenticate_user!) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:user)).to eq(user) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to render_template 'users/show' }
    end
  end

  describe '#index' do
    before do
      allow(user).to receive(:company).and_return(company)
      allow(company).to receive(:users).and_return(users)
      allow(users).to receive(:eager_load).with(:roles).and_return(users)
      allow(users).to receive(:search).with('example').and_return(users)
      allow(users).to receive(:result).and_return(users)
      allow(users).to receive(:page).with(nil).and_return(users)
      allow(users).to receive(:per).with(20).and_return(users)
    end

    def send_request
      get :index, { q: 'example' }
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(user).to receive(:company).and_return(company) }
      it { expect(company).to receive(:users).and_return(users) }
      it { expect(users).to receive(:eager_load).with(:roles).and_return(users) }
      it { expect(users).to receive(:search).with('example').and_return(users) }
      it { expect(users).to receive(:result).and_return(users) }
      it { expect(users).to receive(:page).with(nil).and_return(users) }
      it { expect(users).to receive(:per).with(20).and_return(users) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:search)).to eq(users) }
      it { expect(assigns(:users)).to eq(users) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template :index }
    end
  end

  describe '#create' do
    before do
      allow(controller).to receive(:user_params)
      allow(controller).to receive(:remove_empty_element_multiple_select)
      allow(user).to receive(:company).and_return(company)
      allow(user).to receive(:account_owner?).and_return(true)
      allow(company).to receive(:users).and_return(users)
      allow(users).to receive(:build).and_return(user)
      allow(user).to receive(:save).and_return(true)
    end

    def send_request
      post :create, user: { name: 'Test User', email: 'test_email@email.com' }
    end

    describe 'expects to send' do
      it { expect(controller).to receive(:remove_empty_element_multiple_select) }
      it { expect(controller).to receive(:user_params) }
      it { expect(user).to receive(:company).and_return(company) }
      it { expect(company).to receive(:users).and_return(users) }
      it { expect(users).to receive(:build).and_return(user) }
      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:user)).to eq(user) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to user_path(user) }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("User #{ user.name } is successfully created.") }
      end

      context "when user cannot be created" do
        before do
          allow(user).to receive(:save).and_return(false)
          send_request
        end

        it { expect(response).to render_template :new }
        it { expect(response).to have_http_status(200) }
        it { expect(flash[:notice]).to be_nil }
      end
    end

  end

  describe '#update' do
    before do
      allow(controller).to receive(:remove_empty_element_multiple_select)
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:update).and_return(true)
      allow(user).to receive(:account_owner?).and_return(true)
    end

    def send_request
      patch :update, id: user, user: { name: 'Test User', email: 'test_email@email.com' }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:user)).to eq(user) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to user_path(user) }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("User #{ user.name } is successfully updated.") }
      end

      context "when user cannot be updated" do
        before do
          allow(user).to receive(:update).and_return(false)
          send_request
        end

        it { expect(response).to render_template :edit }
        it { expect(response).to have_http_status(200) }
        it { expect(flash[:notice]).to be_nil }
      end
    end
  end
end
