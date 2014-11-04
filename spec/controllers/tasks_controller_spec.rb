require 'rails_helper'


describe TasksController do
  let(:user) { mock_model(User) }
  let(:track) { mock_model(Track) }
  let(:task) { mock_model(Task) }
  let(:exercise_task) { mock_model(ExerciseTask) }
  let(:ability) { double(Ability) }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
    allow(controller).to receive(:get_track)
  end


  describe '#create' do
    before do
      allow(controller).to receive(:task_params)
    end

    context 'task create' do
      before do
        allow(Task).to receive(:new).and_return(task)
        allow(task).to receive(:save).and_return(true)
      end

      def send_request
        post :create, track_id: '1', task: { title: 'Test Title', need_review: '0' }
      end

      describe 'expects to send' do
        it { expect(controller).to receive(:task_params) }
        it { expect(Task).to receive(:new).and_return(task) }
        it { expect(task).to receive(:save).and_return(true) }
        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:task)).to eq(task) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to track_tasks_path }
          it { expect(response).to have_http_status(302) }
          it { expect(flash[:notice]).to eq("Task #{ task.title } is successfully created.") }
        end

        context "when task cannot be created" do
          before do
            allow(task).to receive(:save).and_return(false)
            send_request
          end

          it { expect(response).to render_template :new }
          it { expect(response).to have_http_status(200) }
          it { expect(flash[:notice]).to be_nil }
        end
      end
    end

    context 'exercise_task create' do

      before do
        allow(ExerciseTask).to receive(:new).and_return(exercise_task)
        allow(exercise_task).to receive(:save).and_return(true)
        allow(exercise_task).to receive(:task).and_return(task)
        allow(exercise_task).to receive(:title)
      end

      def send_request
        post :create, track_id: '1', task: { title: 'Test Title', need_review: '1' }
      end

      describe 'expects to send' do
        it { expect(controller).to receive(:task_params) }
        it { expect(ExerciseTask).to receive(:new).and_return(exercise_task) }
        it { expect(exercise_task).to receive(:save).and_return(true) }
        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:task)).to eq(task) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to track_tasks_path }
          it { expect(response).to have_http_status(302) }
          it { expect(flash[:notice]).to eq("Task #{ exercise_task.title } is successfully created.") }
        end

        context "when task cannot be created" do
          before do
            allow(exercise_task).to receive(:save).and_return(false)
            send_request
          end

          it { expect(response).to render_template :new }
          it { expect(response).to have_http_status(200) }
          it { expect(flash[:notice]).to be_nil }
        end
      end
    end
  end

  describe '#update' do
    context 'update exercise_task' do
      before do
        allow(Task).to receive(:find).and_return(task)
        allow(task).to receive(:specific).and_return(exercise_task)
        allow(exercise_task).to receive(:task).and_return(task)
        allow(exercise_task).to receive(:update).and_return(true)
        allow(exercise_task).to receive(:title)
      end

      def send_request
        patch :update, id: task, track_id: '1', task: { title: 'Test Title', need_review: '1' }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:task)).to eq(task) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to track_tasks_path }
          it { expect(response).to have_http_status(302) }
          it { expect(flash[:notice]).to eq("Task #{ task.title } is successfully updated.") }
        end

        context "when task cannot be updated" do
          before do
            allow(exercise_task).to receive(:update).and_return(false)
            send_request
          end

          it { expect(response).to render_template :edit }
          it { expect(response).to have_http_status(200) }
          it { expect(flash[:notice]).to be_nil }
        end
      end
    end


    context 'update task' do
      before do
        allow(Task).to receive(:find).and_return(task)
        allow(task).to receive(:specific).and_return(nil)
        allow(task).to receive(:update).and_return(true)
      end

      def send_request
        patch :update, id: task, track_id: '1', task: { title: 'Test Title', need_review: '0' }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:task)).to eq(task) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to track_tasks_path }
          it { expect(response).to have_http_status(302) }
          it { expect(flash[:notice]).to eq("Task #{ task.title } is successfully updated.") }
        end

        context "when task cannot be updated" do
          before do
            allow(task).to receive(:update).and_return(false)
            send_request
          end

          it { expect(response).to render_template :edit }
          it { expect(response).to have_http_status(200) }
          it { expect(flash[:notice]).to be_nil }
        end
      end
    end
  end


end