require 'rails_helper'

RSpec.describe CompaniesController, :type => :controller do
  let(:company) { mock_model(Company) }
  let(:companies) { double(ActiveRecord::Relation) }
  let(:user) { mock_model(User) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
  end
  
  describe '#new' do
    before do
      allow(Company).to receive(:new).and_return(company)
      allow(company).to receive(:users).and_return(users)
      allow(users).to receive(:build).and_return(user)
    end

    def send_request
      get :new
    end

    describe 'expects to receive' do
      after do
        send_request
      end

      it { expect(Company).to receive(:new).and_return(company) }
      it { expect(company).to receive(:users).and_return(users) }
      it { expect(users).to receive(:build).and_return(user) }
    end

    describe 'assigns' do
      before do
        send_request
      end

      it { expect(assigns(:company)).to eq(company) }
    end

    describe 'response' do
      before do
        send_request
      end

      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template 'companies/new' }
    end
  end


  describe '#index' do
    before do
      allow(Company).to receive(:accessible_by).and_return(companies)
      allow(companies).to receive(:search).and_return(companies)
      allow(companies).to receive(:result).and_return(companies)
      allow(ability).to receive(:has_block?).and_return(false)
    end

    def send_request
      get :index
    end

    describe 'expects to receive' do
      after do
        send_request
      end

      it { expect(companies).to receive(:search).and_return(companies) }
    end

    describe 'assigns' do
      before do
        send_request
      end

      it { expect(assigns(:companies)).to eq(companies) }
    end

    describe 'response' do
      before do
        send_request
      end

      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template 'index' }
    end
  end


  describe '#toggle_enabled' do
    before do
      allow(Company).to receive(:find).and_return(company)
      allow(company).to receive(:toggle!).and_return(true)
    end

    def send_request
      xhr :patch, :toggle_enabled, id: company.id
    end

    describe 'expects to receive' do
      after do
        send_request
      end

      it { expect(company).to receive(:toggle!).and_return(true) }
    end

    describe 'assigns' do
      before do
        send_request
      end

      it { expect(assigns(:company)).to eq(company) }
    end

    describe 'response' do
      before do
        send_request
      end

      it { expect(response).to have_http_status(200) }
    end
  end


end