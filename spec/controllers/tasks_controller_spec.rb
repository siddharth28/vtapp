require 'rails_helper'


describe TasksController do
  let(:user) { mock_model(User) }
  let(:track) { mock_model(Track) }
  let(:task) { mock_model(Task) }
  let(:company) { mock_model(Company) }
  let(:tasks) { double(ActiveRecord::Relation) }
  let(:tracks) { double(ActiveRecord::Relation) }
  let(:exercise_task) { mock_model(ExerciseTask) }
  let(:ability) { double(Ability) }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
    allow(controller).to receive(:current_company).and_return(company)
    allow(company).to receive(:tracks).and_return(tracks)
    allow(tracks).to receive(:find_by).and_return(track)
  end


  describe '#index' do

    before do
      allow(track).to receive(:tasks).and_return(tasks)
      allow(controller).to receive(:authorize!)
    end

    def send_request
      get :index, track_id: track.id
    end

    context 'no tasks' do
      before { allow(tasks).to receive(:blank?).and_return(true) }

      describe 'expects to receive' do
        it { expect(track).to receive(:tasks).and_return(tasks) }
        it { expect(tasks).to receive(:blank?).and_return(true) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }

        it { expect(assigns(:tasks)).to eq(tasks) }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(200) }
        it { expect(response).to render_template :index }
        it { expect(flash[:alert]).to eq("Track: #{ track.name } has no tasks at this moment") }
      end
    end

    context 'tasks present' do
      before do
        allow(tasks).to receive(:blank?).and_return(false)
        allow(tasks).to receive(:includes).with(:actable).and_return(tasks)
        allow(tasks).to receive(:nested_set).and_return(tasks)
        allow(tasks).to receive(:all).and_return(tasks)
      end

      describe 'expects to receive' do
        it { expect(track).to receive(:tasks).and_return(tasks) }
        it { expect(tasks).to receive(:blank?).and_return(false) }
        it { expect(tasks).to receive(:includes).with(:actable).and_return(tasks) }
        it { expect(tasks).to receive(:nested_set).and_return(tasks) }
        it { expect(tasks).to receive(:all).and_return(tasks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }

        it { expect(assigns(:tasks)).to eq(tasks) }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(200) }
        it { expect(response).to render_template :index }
      end

    end
  end

  describe '#new' do
    before do
      allow(track).to receive(:tasks).and_return(tasks)
      allow(tasks).to receive(:build).and_return(task)
    end


    def send_request
      get :new, track_id: track.id
    end

    describe 'expects to send' do
      it { expect(track).to receive(:tasks).and_return(tasks) }
      it { expect(tasks).to receive(:build).and_return(tasks) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:task)).to eq(task) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to render_template :new }
      it { expect(response).to have_http_status(200) }
    end

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
        post :create, track_id: track.id, task: { title: 'Test Title', need_review: '0' }
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
          it { expect(response).to redirect_to manage_track_tasks_path(track) }
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
        post :create, track_id: track.id, task: { title: 'Test Title', need_review: '1' }
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
          it { expect(response).to redirect_to manage_track_tasks_path(track) }
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
        patch :update, id: task, track_id: track.id, task: { title: 'Test Title', need_review: '1' }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:task)).to eq(task) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to manage_track_tasks_path(track) }
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
        patch :update, id: task, track_id: track.id, task: { title: 'Test Title', need_review: '0' }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:task)).to eq(task) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to manage_track_tasks_path(track) }
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

  describe '#destroy' do
    before do
      allow(Task).to receive(:find).and_return(task)
      allow(task).to receive(:destroy)
    end

    def send_request
      delete :destroy, track_id: track.id, id: task
    end

    describe 'expects to send' do
      it { expect(Task).to receive(:find).and_return(task) }
      it { expect(task).to receive(:destroy) }

      after { send_request }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to redirect_to manage_track_tasks_path(track) }
      it { expect(response).to have_http_status(302) }
      it { expect(flash[:notice]).to eq("Task #{ task.title } is successfully deleted.") }
    end
  end

  describe '#manage' do

    before do
      allow(track).to receive(:tasks).and_return(tasks)
      allow(controller).to receive(:authorize!)
    end

    def send_request
      get :manage, track_id: track.id
    end

    context 'no tasks' do
      before { allow(tasks).to receive(:blank?).and_return(true) }

      describe 'expects to receive' do
        it { expect(track).to receive(:tasks).and_return(tasks) }
        it { expect(tasks).to receive(:blank?).and_return(true) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }

        it { expect(assigns(:tasks)).to eq(tasks) }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(200) }
        it { expect(response).to render_template :manage }
        it { expect(flash[:alert]).to eq("Track: #{ track.name } has no tasks at this moment") }
      end
    end

    context 'tasks present' do
      before do
        allow(tasks).to receive(:blank?).and_return(false)
        allow(tasks).to receive(:nested_set).and_return(tasks)
        allow(tasks).to receive(:all).and_return(tasks)
      end

      describe 'expects to receive' do
        it { expect(track).to receive(:tasks).and_return(tasks) }
        it { expect(tasks).to receive(:blank?).and_return(false) }
        it { expect(tasks).to receive(:nested_set).and_return(tasks) }
        it { expect(tasks).to receive(:all).and_return(tasks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }

        it { expect(assigns(:tasks)).to eq(tasks) }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(200) }
        it { expect(response).to render_template :manage }
      end

    end
  end


  describe '#sample_solution' do
    let(:sample_solution) { instance_double('Paperclip::Attachment') }


    before do
      allow(Task).to receive(:find).and_return(task)
      allow(task).to receive(:sample_solution).and_return(sample_solution)
      allow(sample_solution).to receive(:path)
      allow(controller).to receive(:send_file).with(task.sample_solution.path)
      allow(controller).to receive(:render)
    end

    def send_request
      get :sample_solution, track_id: track.id, id: task.id
    end

    describe 'expects to receive' do
      it { expect(task).to receive(:sample_solution).and_return(sample_solution) }
      it { expect(sample_solution).to receive(:path) }
      it { expect(controller).to receive(:send_file).with(task.sample_solution.path) }

      after { send_request }
    end

    describe 'response' do
      before { send_request }

      it { expect(response).to have_http_status(200) }
    end

  end

  describe '#remove_sample_solution' do

    before do
      allow(Task).to receive(:find).and_return(task)
      allow(task).to receive(:specific).and_return(exercise_task)
      allow(exercise_task).to receive(:sample_solution=).with(nil)
      allow(task).to receive(:save).and_return(true)
    end

    def send_request
      get :remove_sample_solution, track_id: track.id, id: task.id
    end

    describe 'expects to receive' do
      it { expect(Task).to receive(:find).and_return(task) }
      it { expect(task).to receive(:specific).and_return(exercise_task) }
      it { expect(exercise_task).to receive(:sample_solution=).with(nil) }
      it { expect(task).to receive(:save).and_return(true) }

      after { send_request }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to redirect_to edit_track_task_path }
      it { expect(response).to have_http_status(302) }
    end
  end

end