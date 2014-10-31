require 'rails_helper'

describe UsersController do
  let(:user) { mock_model(User) }
  let(:company) { mock_model(Company) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }
  let(:usertasks) { double(ActiveRecord::Relation) }
  let(:usertask) { mock_model(Usertask) }
  let(:task) { mock_model(Task) }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#show' do
    before do
      allow(user).to receive(:usertasks).and_return(usertasks)
      allow(usertasks).to receive(:find_by).with(task_id: task.id).and_return(usertask)
    end

    def send_request
      get :show, { task_id: task.id, id: usertask.id }
    end

    describe 'expects to send' do
      it { expect(user).to receive(:usertasks).and_return(usertasks) }
      it { expect(usertasks).to receive(:find_by).with(task_id: task.id).and_return(usertask) }
      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:usertask)).to eq(usertask) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to render_template :show }
    end
  end

  describe '#create' do
    before do
      allow(user).to receive(:usertasks).and_return(usertasks)
      allow(usertasks).to receive(:build).with(task_id: task.id).and_return(usertask)
      allow(usertask).to receive(:save).and_return(usertask)
    end

    def send_request
      post :create, usertask: { task_id: task.id, user_id: user.id }
    end

    describe 'expects to send' do
      it { expect(user).to receive(:usertasks).and_return(usertasks) }
      it { expect(usertasks).to receive(:build).with(task_id: task.id).and_return(usertask) }
      it { expect(usertask).to receive(:save).and_return(usertask) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:usertask)).to eq(usertask) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to action: :show }
        it { expect(response).to have_http_status(302) }
      end

      context "when user cannot be created" do
        before do
          allow(user).to receive(:save).and_return(false)
          send_request
        end

        it { expect(response).to render_template :new }
        it { expect(response).to have_http_status(200) }
      end
    end
  end

  describe '#update' do
    before do
      allow(usertask).to receive(:submit_task).and_return(true)
    end

    def send_request
      patch :update, id: usertask.id, usertask: { task_id: task.id, user_id: user.id }
    end

    describe 'expects to send' do
      it { expect(user).to receive(:submit_task).and_return(true) }
      after { send_request }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to redirect_to action: :show }
      it { expect(response).to have_http_status(302) }
    end
  end

  describe '#usertask_params' do
    before do
      allow(Usertask).to receive(:new).with({ task_id: 1, user_id: 1 }.with_indifferent_access).and_return(usertask)
      allow(user).to receive(:usertasks).and_return(usertasks)
      allow(usertasks).to receive(:build).with(task_id: "1").and_return(usertask)
      allow(usertasks).to receive(:save).and_return(usertask)
    end

    def send_request
      post :create, usertask: { task_id: 1, user_id: 1, name: 'Alpha' }
    end

    describe 'expects to send' do
      it { expect(Usertask).to receive(:new).with({ task_id: 1, user_id: 1 }.with_indifferent_access).and_return(usertask) }

      after { send_request }
    end
  end
end
