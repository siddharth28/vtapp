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

  describe '#start_task' do
    before do
      allow(user).to receive(:usertasks).and_return(usertasks)
      allow(usertasks).to receive(:create).and_return(usertask)
      allow(usertasks).to receive(:find_by).with(task_id: "1").and_return(usertask)
    end

    def send_request
      get :start_task, usertask: { task_id: 1, user_id: 1 }
    end

    describe 'expects to send' do
      it { expect(user).to receive(:usertasks).and_return(usertasks) }
      it { expect(usertasks).to receive(:create).and_return(usertask) }
      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:usertask)).to eq(usertask) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to redirect_to action: :task_description, id: usertask }
      it { expect(response).to have_http_status(302) }
    end
  end

  describe '#submit_task' do
    before do
      allow(Usertask).to receive(:find).and_return(usertask)
    end

    context 'ExerciseTask with no url && no comment' do
      before do
        allow(usertask).to receive(:task).and_return(task)
        allow(task).to receive(:specific).and_return(exercise_task)
      end

      def send_request
        xhr :patch, :submit_task, { usertask: { url: '', comment: '' }, id: usertask }
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:task).and_return(task) }
        it { expect(task).to receive(:specific).and_return(exercise_task) }
        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
        it { expect(usertask.errors[:url]).to eq(['Either url or comment needs to be present for submission']) }
        it { expect(usertask.errors[:comment]).to eq(['Either url or comment needs to be present for submission']) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to render_template :task_description }
        it { expect(response).to have_http_status(200) }
      end
    end

    context 'ExerciseTask with url && comment' do
      before do
        allow(usertask).to receive(:task).and_return(task)
        allow(task).to receive(:specific).and_return(exercise_task)
        allow(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }).and_return(usertasks)
      end

      def send_request
        xhr :patch, :submit_task, { usertask: { url: 'http://Example.com', comment: 'Comment' }, id: usertask }
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:task).and_return(task) }
        it { expect(task).to receive(:specific).and_return(exercise_task) }
        it { expect(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }).and_return(usertasks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to redirect_to action: :task_description, id: usertask }
        it { expect(response).to have_http_status(302) }
      end
    end

    context 'ExerciseTask with no url && comment' do
      before do
        allow(usertask).to receive(:task).and_return(task)
        allow(task).to receive(:specific).and_return(exercise_task)
        allow(usertask).to receive(:submit_task).with({ url: '', comment: 'Comment' }).and_return(usertasks)
      end

      def send_request
        xhr :patch, :submit_task, { usertask: { url: '', comment: 'Comment' }, id: usertask }
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:task).and_return(task) }
        it { expect(task).to receive(:specific).and_return(exercise_task) }
        it { expect(usertask).to receive(:submit_task).with({ url: '', comment: 'Comment' }).and_return(usertasks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to redirect_to action: :task_description, id: usertask }
        it { expect(response).to have_http_status(302) }
      end
    end


    context 'ExerciseTask with url && no comment' do
      before do
        allow(usertask).to receive(:task).and_return(task)
        allow(task).to receive(:specific).and_return(exercise_task)
        allow(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: '' }).and_return(usertasks)
      end

      def send_request
        xhr :patch, :submit_task, { usertask: { url: 'http://Example.com', comment: '' }, id: usertask }
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:task).and_return(task) }
        it { expect(task).to receive(:specific).and_return(exercise_task) }
        it { expect(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: '' }).and_return(usertasks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to redirect_to action: :task_description, id: usertask }
        it { expect(response).to have_http_status(302) }
      end
    end

    context 'normal task' do
      before do
        allow(usertask).to receive(:task).and_return(task)
        allow(task).to receive(:specific).and_return(nil)
        allow(usertask).to receive(:submit_task).and_return(usertasks)
      end

      def send_request
        patch :submit_task, id: usertask
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:task).and_return(task) }
        it { expect(task).to receive(:specific).and_return(nil) }
        it { expect(usertask).to receive(:submit_task).and_return(usertasks) }
        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:usertask)).to eq(usertask) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to redirect_to action: :task_description, id: usertask }
        it { expect(response).to have_http_status(302) }
      end
    end
  end

  describe '#task_description' do
    before do
      allow(Usertask).to receive(:find).and_return(usertask)
    end

    def send_request
      get :task_description, id: usertask
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:usertask)).to eq(usertask) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to render_template :task_description }
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
      patch :submit_task, { usertask: { url: 'http://Example.com', comment: 'Comment', name: 'Test' }, id: usertask }
    end

    describe 'expects to send' do
      it { expect(usertask).to receive(:submit_task).with({ url: 'http://Example.com', comment: 'Comment' }.with_indifferent_access).and_return(usertasks) }
      after { send_request }
    end
  end
end
