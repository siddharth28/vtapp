require 'rails_helper'

describe UsersController do
  let(:user) { mock_model(User) }
  let(:company) { mock_model(Company) }
  let(:current_user) { mock_model(User) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }
  let(:usertasks) { double(ActiveRecord::Relation) }
  let(:usertask) { mock_model(Usertask) }

  def sign_in(user)
    if user.nil?
      allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, {:scope => :user})
      allow(controller).to receive(:current_user).and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end

  before do
    sign_in(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
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
      it { expect(User).to receive(:find).and_return(user) }
      it { expect(controller).to receive(:authenticate_user!) }
      after { send_request }
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
      allow(users).to receive(:includes).with(:roles).and_return(users)
      allow(users).to receive(:search).with({ s: "name {name:'asc'}" }).and_return(users)
      allow(users).to receive(:result).and_return(users)
      allow(users).to receive(:page).with(nil).and_return(users)
      allow(users).to receive(:per).with(20).and_return(users)
    end

    def send_request
      get :index, q: { s: "name {name:'asc'}" }
    end

    describe 'expects to receive' do
      it { expect(user).to receive(:company).and_return(company) }
      it { expect(company).to receive(:users).and_return(users) }
      it { expect(users).to receive(:includes).with(:roles).and_return(users) }
      it { expect(users).to receive(:search).with({ s: "name {name:'asc'}" }).and_return(users) }
      it { expect(users).to receive(:result).and_return(users) }
      it { expect(users).to receive(:page).with(nil).and_return(users) }
      it { expect(users).to receive(:per).with(20).and_return(users) }
      after { send_request }
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

    describe 'expects to send' do
      it { expect(User).to receive(:find).and_return(user) }
      it { expect(user).to receive(:update).and_return(true) }
      it { expect(user).to receive(:account_owner?).and_return(true) }
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

  describe '#start_task' do
    before do
      allow(user).to receive(:usertasks).and_return(usertasks)
      allow(usertasks).to receive(:create).and_return(usertask)
      allow(usertasks).to receive(:find_by).with(task_id: "1").and_return(usertask)
    end

    def send_request
      get :start_task, { task_id: 1, user_id: 1 }
    end

    describe 'expects to send' do
      it { expect(user).to receive(:usertasks).and_return(usertasks) }
      it { expect(usertasks).to receive(:create).and_return(usertask) }
      after { send_request }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to redirect_to action: :task_description, task_id: 1 }
      it { expect(response).to have_http_status(302) }
    end
  end

  describe '#task_description' do
    before do
      allow(user).to receive(:usertasks).and_return(usertasks)
      allow(usertasks).to receive(:find_by).with(task_id: "1").and_return(usertask)
    end

    def send_request
      get :task_description, { task_id: 1, user_id: 1 }
    end

    describe 'expects to send' do
      it { expect(user).to receive(:usertasks).and_return(usertasks) }
      it { expect(usertasks).to receive(:find_by).with(task_id: "1").and_return(usertask) }
      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:usertask)).to eq(usertask) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template :task_description }
    end
  end

  describe '#submit_task' do
    before do
      allow(user).to receive(:submit).with({"url"=>"http://Example.com", "comment"=>"Comment"}, "1").and_return(usertasks)
    end

    def send_request
      patch :submit_task, { usertask: { url: 'http://Example.com', comment: 'Comment' }, task_id: 1, user_id: 1 }
    end

    describe 'expects to send' do
      it { expect(user).to receive(:submit).with({"url"=>"http://Example.com", "comment"=>"Comment"}, "1").and_return(usertasks) }
      after { send_request }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to redirect_to action: :task_description, task_id: 1 }
      it { expect(response).to have_http_status(302) }
    end
  end
end
