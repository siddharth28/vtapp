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
  let(:urls) { double(ActiveRecord::Relation) }
  let(:comments) { double(ActiveRecord::Relation) }
  let(:url) { mock_model(Url) }
  let(:comment) { mock_model(Comment) }
  let(:track) { mock_model(Track) }

  before do
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
    allow(Usertask).to receive(:find).and_return(usertask)
    allow(usertask).to receive(:comments).and_return(comments)
    allow(usertask).to receive(:urls).and_return(urls)
  end

  describe '#start' do
    before do
      allow(usertask).to receive(:not_started?).and_return(true)
      allow(usertask).to receive(:start!)
    end

    def send_request
      get :start, id: usertask.id
    end

    describe 'expects to send' do
      it { expect(usertask).to receive(:start!) }
      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:usertask)).to eq(usertask) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to redirect_to(usertask) }
      it { expect(response).to have_http_status(302) }
    end
  end

  describe '#restart' do

    before do
      allow(usertask).to receive(:restart?).and_return(true)
      allow(usertask).to receive(:restart!)
    end

    def send_request
      get :restart, id: usertask.id
    end

    describe 'expects to receive' do
      it { expect(usertask).to receive(:restart?).and_return(true) }
      it { expect(usertask).to receive(:restart!) }

      after { send_request }
    end

    describe 'response' do
      before { send_request }

      it { expect(response).to have_http_status(302) }
      it { expect(response).to redirect_to(usertask) }
    end
  end

  describe '#submit_url' do

    before do
      allow(Usertask).to receive(:find).and_return(usertask)
      allow(usertask).to receive(:urls).and_return(urls)
      allow(urls).to receive(:find_or_initialize_by).with({name: 'http://Example.com'}).and_return(url)
    end

    def send_request
      post :submit_url, { url: { name: 'http://Example.com' }, id: usertask }
    end

    context 'url submitted successfully' do
      before do
        allow(url).to receive(:save).and_return(true)
        allow(url).to receive(:add_submission_comment)
        allow(usertask).to receive(:task).and_return(task)
      end

      context 'task status submitted' do
        before do
          allow(usertask).to receive(:in_progress?).and_return(false)
          allow(usertask).to receive(:submit!)
        end

        describe 'expects to send' do
          it { expect(usertask).to receive(:urls).and_return(urls) }
          it { expect(urls).to receive(:find_or_initialize_by).with({ name: 'http://Example.com' }).and_return(url) }
          it { expect(url).to receive(:save).and_return(true) }
          it { expect(url).to receive(:add_submission_comment) }
          it { expect(usertask).to receive(:in_progress?).and_return(false) }
          it { expect(usertask).not_to receive(:submit!) }

          after { send_request }
        end

        describe 'assigns' do
          before { send_request }

          it { expect(assigns(:usertask)).to eq(usertask) }
        end

        describe 'response' do
          before { send_request }

          it { expect(response).to have_http_status(302) }
          it { expect(response).to redirect_to(usertask) }
          it { expect(flash[:notice]).to eq("Task #{ usertask.task.title } is successfully submitted") }
        end
      end

      context 'task status in_progress' do
        before do
          allow(usertask).to receive(:in_progress?).and_return(true)
          allow(usertask).to receive(:submit!)
        end

        describe 'expects to send' do
          it { expect(usertask).to receive(:urls).and_return(urls) }
          it { expect(urls).to receive(:find_or_initialize_by).with({ name: 'http://Example.com' }).and_return(url) }
          it { expect(url).to receive(:save).and_return(true) }
          it { expect(url).to receive(:add_submission_comment) }
          it { expect(usertask).to receive(:in_progress?).and_return(true) }
          it { expect(usertask).to receive(:submit!) }

          after { send_request }
        end

        describe 'assigns' do
          before { send_request }

          it { expect(assigns(:usertask)).to eq(usertask) }
        end

        describe 'response' do
          before { send_request }

          it { expect(response).to have_http_status(302) }
          it { expect(response).to redirect_to(usertask) }
          it { expect(flash[:notice]).to eq("Task #{ usertask.task.title } is successfully submitted") }
        end
      end
    end

    context 'url not submitted successfully' do
      before do
        allow(url).to receive(:save).and_return(false)
        allow(usertask).to receive(:comments).and_return(comments)
        allow(comments).to receive(:build).and_return(comment)
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(200) }
        it { expect(response).to render_template(:show) }
      end

    end
  end

  describe '#submit_comment' do

    before do
      allow(usertask).to receive(:comments).and_return(comments)
      allow(comments).to receive(:build).with({data: 'New Comment', commenter: user}).and_return(comment)
    end

    def send_request
      post :submit_comment, { comment: { data: 'New Comment' }, id: usertask }
    end

    context 'Comment successfully submitted' do
      before { allow(comment).to receive(:save).and_return(true) }

      describe 'expects to send' do
        it { expect(usertask).to receive(:comments).and_return(comments) }
        it { expect(comments).to receive(:build).with({data: 'New Comment', commenter: user}).and_return(comment) }
        it { expect(comment).to receive(:save).and_return(true) }

        after { send_request }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to(usertask) }
        it { expect(flash[:notice]).to eq("Comment added") }
      end
    end

    context 'Comment not submitted' do
      before do
        allow(comment).to receive(:save).and_return(false)
        allow(usertask).to receive(:urls).and_return(urls)
        allow(usertask).to receive(:user).and_return(user)
        allow(urls).to receive(:build).and_return(url)
      end

      describe 'expects to send' do
        it { expect(usertask).to receive(:comments).and_return(comments) }
        it { expect(comments).to receive(:build).with({data: 'New Comment', commenter: user}).and_return(comment) }
        it { expect(comment).to receive(:save).and_return(false) }
        it { expect(usertask).to receive(:urls).and_return(urls) }
        it { expect(urls).to receive(:build).and_return(url) }

        after { send_request }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(200) }
        it { expect(response).to render_template(:show) }
      end
    end
  end

  describe '#resubmit' do
    before do
      allow(usertask).to receive(:submit!)
      allow(usertask).to receive(:urls).and_return(urls)
      allow(urls).to receive(:order).and_return(urls)
      allow(urls).to receive(:first).and_return(url)
      allow(url).to receive(:add_submission_comment)
    end

    def send_request
      post :resubmit, id: usertask.id
    end

    context 'usertask state in_progress' do

      before { allow(usertask).to receive(:in_progress?).and_return(true) }

      describe 'expects to receive' do
        it { expect(usertask).to receive(:in_progress?).and_return(true) }
        it { expect(usertask).to receive(:submit!) }
        it { expect(usertask).to receive(:urls).and_return(urls) }
        it { expect(urls).to receive(:order).and_return(urls) }
        it { expect(urls).to receive(:first).and_return(url) }
        it { expect(url).to receive(:add_submission_comment) }

        after { send_request }

      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to(usertask) }
      end

    end

  end

  describe '#assign_to_me' do
    let(:user2) { mock_model(User) }

    before do
      allow(usertask).to receive(:task).and_return(task)
      allow(task).to receive(:track).and_return(track)
    end

    def send_request
      put :assign_to_me, id: usertask.id
    end

    context 'usertask cannot be assigned' do
      before do
        allow(usertask).to receive(:user).and_return(user)
      end

      describe 'expects to receive' do
        it { expect(usertask).to receive(:user).and_return(user) }
        it { expect(usertask).to receive(:task).and_return(task) }
        it { expect(task).to receive(:track).and_return(track) }

        after { send_request }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to(assigned_to_others_for_review_track_tasks_path(track)) }
        it { expect(flash[:alert]).to eq("Cannot change the reviewer of your own task") }
      end
    end

    context 'usertask can be assigned' do
      before do
        allow(usertask).to receive(:user).and_return(user2)
        allow(usertask).to receive(:update_attributes).with({reviewer: user})
      end

      describe 'expects to receive' do
        it { expect(usertask).to receive(:user).and_return(user2) }
        it { expect(usertask).to receive(:update_attributes).with({reviewer: user}) }

        after { send_request }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to(assigned_to_others_for_review_track_tasks_path(track)) }
      end
    end
  end

  describe '#review_exercise' do
    before do
      allow(usertask).to receive(:submitted?).and_return(true)
      allow(usertask).to receive(:comments).and_return(comments)
      allow(comments).to receive(:create).and_return(comment)
    end

    context 'task accepted' do

      before { allow(usertask).to receive(:accept!).and_return(true) }

      def send_request
        patch :review_exercise, id: usertask.id, usertask: { comment: 'comment' }, task_status: 'accept'
      end

      describe 'expects to receive' do

        it { expect(usertask).to receive(:accept!) }
        it { expect(usertask).to receive(:comments).and_return(comments) }
        it { expect(comments).to receive(:create).and_return(comment) }

        after { send_request }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to(usertask) }
      end
    end

    context 'task rejected' do

      before { allow(usertask).to receive(:reject!).and_return(true) }

      def send_request
        patch :review_exercise, id: usertask.id, usertask: { comment: 'comment' }, task_status: 'reject'
      end

      describe 'expects to receive' do

        it { expect(usertask).to receive(:reject!) }
        it { expect(usertask).to receive(:comments).and_return(comments) }
        it { expect(comments).to receive(:create).and_return(comment) }

        after { send_request }
      end

      describe 'response' do
        before { send_request }

        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to(usertask) }
      end
    end
  end

end
