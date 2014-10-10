require 'rails_helper'

describe CompaniesController do
  let(:company) { mock_model(Company) }
  let(:companies) { double(ActiveRecord::Relation) }
  let(:user) { mock_model(User) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }
  let(:roles) { double(ActiveRecord::Relation) }
  let(:role) { mock_model(Role) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#create' do
    #FIXED Allow works as a stub
    #FIXME Stub the calls inside before block.
    before do
      allow(Company).to receive(:new).and_return(company)
      allow(company).to receive(:save).and_return(true)
    end

    def send_request
      post :create, company: { name: 'Test Company' }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(Company).to receive(:new).and_return(company) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:company)).to eq(company) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to company_path(company) }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("Company #{ company.name } is successfully created.") }
      end

      context "when message cannot be created" do
        before do
          allow(company).to receive(:save).and_return(false)
          send_request
        end

        it { expect(response).to render_template 'companies/new' }
        it { expect(response).to have_http_status(200) }
        it { expect(flash[:notice]).to be_nil }
      end
    end
  end

  describe '#show' do
    before { allow(Company).to receive(:find).and_return(company) }

    def send_request
      get :show, { company: { name: 'Test Company' }, id: company.id }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(Company).to receive(:find).and_return(company) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:company)).to eq(company) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to render_template 'companies/show' }
    end
  end

  describe '#index' do
    before do
      allow(Company).to receive(:load_with_owners).and_return(companies)
      allow(companies).to receive(:search).with('example').and_return(companies)
      allow(companies).to receive(:result).and_return(companies)
      allow(companies).to receive(:page).with(nil).and_return(companies)
      allow(companies).to receive(:per).with(20).and_return(companies)
    end

    def send_request
      get :index, { q: 'example' }
    end
    #FIXED
    #FIXME Also write rspecs of load_with_owners call.
    #FIXED
    #FIXME Test call with arguments.
    describe 'expects to receive' do
      after { send_request }
      it { expect(Company).to receive(:load_with_owners).and_return(companies) }
      it { expect(companies).to receive(:search).with('example').and_return(companies) }
      it { expect(companies).to receive(:result).and_return(companies) }
      it { expect(companies).to receive(:page).with(nil).and_return(companies) }
      it { expect(companies).to receive(:per).with(20).and_return(companies) }
    end

    #FIXED
    #FIXME Check assignment of search instance_variable also.
    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:search)).to eq(companies) }
      it { expect(assigns(:companies)).to eq(companies) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template 'index' }
    end
  end


  describe '#toggle_enabled' do
    #FIXED
    #FIXME Stub the calls inside before block.
    before do
      allow(Company).to receive(:find).and_return(company)
      allow(company).to receive(:toggle!).and_return(true)
    end

    def send_request
      xhr :patch, :toggle_enabled, id: company.id
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(company).to receive(:toggle!).and_return(true) }
    end

    #FIXED
    #FIXME IT is not required

    describe 'response' do
      before { send_request }
      #FIXED
      #FIXME Also test template rendering.
      it { expect(response).to render_template 'companies/toggle_enabled' }
      it { expect(response).to have_http_status(200) }
    end
  end

  describe 'index' do
    def send_request
      get :index, { q: 'example', extra: 'abcd' }
    end

    describe '#skip_load_resource' do
      before { send_request }
      it { expect(assigns(:companies)).not_to eq(companies) }
    end
  end

  describe '#create' do
    #FIXED Allow works as a stub
    #FIXME Stub the calls inside before block.
    before do
      allow(Company).to receive(:new).with({ name: 'Test Company', owner_name: 'Owner', owner_email: 'Email@email.com' }.with_indifferent_access).and_return(company)
      allow(company).to receive(:save).and_return(true)
    end

    def send_request
      post :create, company: { name: 'Test Company', owner_name: 'Owner', owner_email: 'Email@email.com', enabled: false }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(Company).to receive(:new).with({ name: 'Test Company', owner_name: 'Owner', owner_email: 'Email@email.com'}.with_indifferent_access).and_return(company) }
    end
  end
end
