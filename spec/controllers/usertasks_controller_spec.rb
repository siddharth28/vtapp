require 'rails_helper'

describe UsertasksController do
  let(:user) { mock_model(User) }
  let(:company) { mock_model(Company) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }
  let(:usertasks) { double(ActiveRecord::Relation) }
  let(:usertask) { mock_model(Usertask) }
  let(:task) { mock_model(Task) }
  let(:exercise_task) { mock_model(ExerciseTask) }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#start' do
    before do
      allow(user).to receive(:usertasks).and_return(usertasks)
      allow(usertasks).to receive(:build).and_return(usertask)
      allow(usertask).to receive(:task).and_return(task)
      allow(usertasks).to receive(:find_by).with(task_id: "1").and_return(usertask)
    end

    def send_request
      get :start, usertask: { task_id: 1, user_id: 1 }
    end

    context 'save successful' do
      before do
        allow(usertask).to receive(:save).and_return(true)
      end

      describe 'expects to send' do
        it { expect(user).to receive(:usertasks).and_return(usertasks) }
        it { expect(usertasks).to receive(:build).and_return(usertask) }
        it { expect(usertask).to receive(:save).and_return(true) }
        it { expect(usertask).to receive(:task).and_return(task) }
        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to redirect_to action: :description, id: usertask }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("Task #{ usertask.task.title } is successfully started") }
      end
    end

    context 'save unsuccessful' do
      before do
        allow(usertask).to receive(:save).and_return(false)
      end

      describe 'expects to send' do
        it { expect(user).to receive(:usertasks).and_return(usertasks) }
        it { expect(usertasks).to receive(:build).and_return(usertask) }
        it { expect(usertask).to receive(:save).and_return(false) }
        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to render_template :description }
        it { expect(response).to have_http_status(200) }
      end
    end
  end

  describe '#submit' do
    before do
      allow(Usertask).to receive(:find).and_return(usertask)
    end

    def send_request
      xhr :patch, :submit, { usertask: { url: 'http://Example.com', comment: 'Comment' }, id: usertask }
    end

    context 'task submitted' do
      before do
        allow(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }).and_return(true)
        allow(usertask).to receive(:task).and_return(task)
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }).and_return(true) }
        it { expect(usertask).to receive(:task).and_return(task) }
        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to redirect_to action: :description, id: usertask }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("Task #{ usertask.task.title } is successfully submitted") }
      end
    end

    context 'task not submitted' do
      before do
        allow(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }).and_return(false)
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }).and_return(false) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to render_template :description }
        it { expect(response).to have_http_status(200) }
      end
    end
  end

  describe '#description' do
    before do
      allow(Usertask).to receive(:find).and_return(usertask)
    end

    def send_request
      get :description, id: usertask
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:usertask)).to eq(usertask) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to render_template :description }
      it { expect(response).to have_http_status(200) }
    end
  end

  describe '#usertask_params' do
    before do
      allow(Usertask).to receive(:find).and_return(usertask)
      allow(usertask).to receive(:task).and_return(task)
      allow(task).to receive(:specific).and_return(exercise_task)
      allow(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }.with_indifferent_access).and_return(usertasks)
    end

    def send_request
      patch :submit, { usertask: { url: 'http://Example.com', comment: 'Comment', name: 'Test' }, id: usertask }
    end

    describe 'expects to send' do
      it { expect(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }.with_indifferent_access).and_return(usertasks) }
      after { send_request }
    end
  end
end
