require 'rails_helper'

describe TracksController do
  let(:current_company) { mock_model(Company) }
  let(:track) { mock_model(Track)}
  let(:company) { mock_model(Company)}
  let(:ability) { double(Ability) }
  let(:tracks) { double(ActiveRecord::Relation) }
  let(:user) { mock_model(User) }
  let(:role) { mock_model(Role) }
  let(:users) { double(ActiveRecord::Relation) }

  before do
    allow(controller).to receive(:current_company).and_return(current_company)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#index' do
    before do
      allow(tracks).to receive(:load_with_owners).and_return(tracks)
      allow(tracks).to receive(:page).with(nil).and_return(tracks)
      allow(tracks).to receive(:per).with(20).and_return(tracks)
    end

    def send_request
      get :index, { page: nil }
    end

    context 'in case of account_owner' do
      before do
        allow(user).to receive(:account_owner?).and_return(true)
        allow(current_company).to receive(:tracks).and_return(tracks)
      end

      describe 'expects to receive' do
        it { expect(user).to receive(:account_owner?).and_return(true) }
        it { expect(current_company).to receive(:tracks).and_return(tracks) }
        it { expect(tracks).to receive(:load_with_owners).and_return(tracks) }
        it { expect(tracks).to receive(:page).with(nil).and_return(tracks) }
        it { expect(tracks).to receive(:per).with(20).and_return(tracks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:tracks)).to eq(tracks) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(200) }
        it { expect(response.body).to be_blank }
      end
    end

    context 'in case of account_admin' do
      before do
        allow(user).to receive(:account_admin?).and_return(true)
        allow(user).to receive(:account_owner?).and_return(false)
        allow(current_company).to receive(:tracks).and_return(tracks)
      end

      describe 'expects to receive' do
        it { expect(user).to receive(:account_admin?).and_return(true) }
        it { expect(user).to receive(:account_owner?).and_return(false) }
        it { expect(current_company).to receive(:tracks).and_return(tracks) }
        it { expect(tracks).to receive(:load_with_owners).and_return(tracks) }
        it { expect(tracks).to receive(:page).with(nil).and_return(tracks) }
        it { expect(tracks).to receive(:per).with(20).and_return(tracks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:tracks)).to eq(tracks) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(200) }
        it { expect(response.body).to be_blank }
      end
    end

    context 'neither account_admin nor account_owner' do
      before do
        allow(user).to receive(:account_owner?).and_return(false)
        allow(user).to receive(:account_admin?).and_return(false)
        allow(user).to receive(:tracks).and_return(tracks)
      end

      describe 'expects to receive' do
        it { expect(user).to receive(:account_owner?).and_return(false) }
        it { expect(user).to receive(:account_admin?).and_return(false) }
        it { expect(user).to receive(:tracks).and_return(tracks) }
        it { expect(tracks).to receive(:load_with_owners).and_return(tracks) }
        it { expect(tracks).to receive(:page).with(nil).and_return(tracks) }
        it { expect(tracks).to receive(:per).with(20).and_return(tracks) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:tracks)).to eq(tracks) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(200) }
        it { expect(response.body).to be_blank }
      end
    end
  end

  describe '#create' do
    before do
      allow(Track).to receive(:new).with(name: 'Test Track').and_return(track)
      allow(current_company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:build).and_return(track)
      allow(track).to receive(:save).and_return(true)
    end

    def send_request
      post :create, track: { name: 'Test Track' }
    end

    describe 'expects to send' do
      # example for #set_company
      it { expect(Track).to receive(:new).with(name: 'Test Track').and_return(track) }
      it { expect(current_company).to receive(:tracks).and_return(tracks) }
      it { expect(tracks).to receive(:build).and_return(track) }
      it { expect(track).to receive(:save).and_return(true) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to tracks_path(company: current_company) }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("Track #{ track.name } is successfully created.") }
      end

      context "when message cannot be created" do
        before do
          allow(track).to receive(:save).and_return(false)
          send_request
        end

        it { expect(response).to render_template :new }
        it { expect(response).to have_http_status(200) }
        it { expect(flash[:notice]).to be_nil }
      end
    end
  end

  describe '#reviewers' do
    before do
      allow(controller).to receive(:set_track).and_return(track)
      allow(Track).to receive(:find).and_return(track)
    end

    def send_request
      get :reviewers, { id: track.id }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template :reviewers }
    end
  end

  describe '#assign_reviewer' do
    before do
      allow(controller).to receive(:set_track).and_return(track)
      allow(Track).to receive(:find).and_return(track)
      allow(track).to receive(:add_track_role).with(:track_reviewer, "123").and_return(user)
    end

    def send_request
      xhr :patch, :assign_reviewer, track: { reviewer_name: 'abc', reviewer_id: "123" }, id: track.id, format: :js
    end

    describe 'expects to receive' do
      it { expect(track).to receive(:add_track_role).with(:track_reviewer, "123").and_return(true) }
      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template 'tracks/assign_reviewer' }
    end
  end

  describe '#update' do
    before do
      allow(Track).to receive(:find).and_return(track)
      allow(track).to receive(:update).and_return(true)
      allow(track).to receive(:replace_owner).with('4').and_return(role)
    end

    def send_request
      patch :update, track: { name: "Rails", description: "a", instructions: "b", references: "c", owner: "tanmay+1@vinsol.com", owner_id: "4" }, id: track
    end

    describe 'expects to receive' do
      it { expect(Track).to receive(:find).and_return(track) }
      it { expect(track).to receive(:update).and_return(true) }
      it { expect(track).to receive(:replace_owner).with('4').and_return(role) }

      after { send_request }
    end


    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to track }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("Track #{ track.name } is successfully updated.") }
      end

      context "when task cannot be updated" do
        before do
          allow(track).to receive(:update).and_return(false)
          send_request
        end

        it { expect(response).to render_template :edit }
        it { expect(response).to have_http_status(200) }
        it { expect(flash[:notice]).to be_nil }
      end
    end
  end



  describe '#remove_reviewer' do
    before do
      allow(controller).to receive(:set_track).and_return(track)
      allow(Track).to receive(:find).and_return(track)
      allow(track).to receive(:remove_track_role).with(:track_reviewer, "123").and_return(user)
    end

    def send_request
      xhr :get, :remove_reviewer, { format: "123", id: track.id }, format: :js
    end

    describe 'expects to receive' do
      it { expect(track).to receive(:remove_track_role).with(:track_reviewer, "123").and_return(user) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template 'tracks/remove_reviewer' }
    end
  end

  describe '#reviewers' do
    before do
      allow(controller).to receive(:set_track).and_return(track)
      allow(Track).to receive(:find).and_return(track)
    end

    def send_request
      get :reviewers, id: track
    end

    describe 'expects to receive' do
      it { expect(controller).to receive(:set_track).and_return(track) }
      it { expect(Track).to receive(:find).and_return(track) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template :reviewers }
    end
  end


  describe '#set_track' do
    before do
      allow(current_company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:find_by).and_return(track)
    end

    it { expect(controller.send(:set_track)).to eql(track) }

    describe 'assigns' do
      before { controller.send(:set_track) }
      it { expect(assigns(:track)).to eq(track) }
    end
  end

  describe '#track_params' do
    before do
      allow(Track).to receive(:new).with({ name: 'Test Track', description: 'Owner', instructions: 'Abcd', references: 'ABCD', enabled: false }.with_indifferent_access).and_return(track)
      allow(current_company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:build).and_return(track)
      allow(track).to receive(:save).and_return(true)
    end

    def send_request
      post :create, track: { name: 'Test Track', description: 'Owner', instructions: 'Abcd', references: 'ABCD', enabled: false, status: true }
    end

    describe 'expects to send' do
      it { expect(Track).to receive(:new).with({ name: 'Test Track', description: 'Owner', instructions: 'Abcd', references: 'ABCD', enabled: false }.with_indifferent_access).and_return(track) }

      after { send_request }
    end
  end

  describe '#search' do
    before do
      allow(current_company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:load_with_owners).and_return(tracks)
      allow(tracks).to receive(:extract).with('Owner', user).and_return(tracks)
      allow(tracks).to receive(:search).with('example').and_return(tracks)
      allow(tracks).to receive(:result).and_return(tracks)
      allow(tracks).to receive(:page).with(nil).and_return(tracks)
      allow(tracks).to receive(:per).with(20).and_return(tracks)
    end

    def send_request
      get :search, { type: 'Owner', q: 'example',  page: nil }
    end

    describe 'expects to receive' do
      it { expect(current_company).to receive(:tracks).and_return(tracks) }
      it { expect(tracks).to receive(:load_with_owners).and_return(tracks) }
      it { expect(tracks).to receive(:extract).with('Owner', user).and_return(tracks) }
      it { expect(tracks).to receive(:search).with('example').and_return(tracks) }
      it { expect(tracks).to receive(:result).and_return(tracks) }
      it { expect(tracks).to receive(:page).with(nil).and_return(tracks) }
      it { expect(tracks).to receive(:per).with(20).and_return(tracks) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }

      it { expect(assigns(:tracks)).to eq(tracks) }
    end

    describe 'response' do
      before { send_request }

      it { expect(response).to render_template :index }
      it { expect(response).to have_http_status(200) }
      it { expect(flash[:notice]).to be_nil }
    end
  end

  describe '#runners' do
    before do
      allow(Track).to receive(:find).and_return(track)
      allow(current_company).to receive(:users).and_return(users)
      allow(users).to receive(:with_role).with(:track_runner, track).and_return(users)
    end

    def send_request
      get :runners, id: track.id
    end

    describe 'expects to receive' do
      it { expect(current_company).to receive(:users).and_return(users) }
      it { expect(users).to receive(:with_role).with(:track_runner, track) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }

      it { expect(assigns(:track_runners)).to eq(users) }
    end

    describe 'response' do
      before { send_request }

      it { expect(response).to render_template :runners }
      it { expect(response).to have_http_status(200) }
      it { expect(flash[:notice]).to be_nil }
    end
  end

  describe 'status' do
    let(:tasks) { double(ActiveRecord::Relation) }

    before do
      allow(Track).to receive(:find).and_return(track)
      allow(current_company).to receive(:users).and_return(users)
      allow(users).to receive(:find_by).and_return(user)
      allow(track).to receive(:tasks).and_return(tasks)
      allow(tasks).to receive(:includes).with(:usertasks).and_return(tasks)
      allow(tasks).to receive(:where).and_return(tasks)
      allow(tasks).to receive(:nested_set).and_return(tasks)
    end

    def send_request
      get :status, id: track.id
    end

    describe 'expects to receive' do

      it { expect(current_company).to receive(:users).and_return(users) }
      it { expect(users).to receive(:find_by).and_return(user) }
      it { expect(track).to receive(:tasks).and_return(tasks) }
      it { expect(tasks).to receive(:includes).with(:usertasks).and_return(tasks) }
      it { expect(tasks).to receive(:where).and_return(tasks) }
      it { expect(tasks).to receive(:nested_set).and_return(tasks) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }

      it { expect(assigns(:tasks)).to eq(tasks) }
    end

    describe 'response' do
      before { send_request }

      it { expect(response).to render_template 'tasks/index' }
      it { expect(response).to have_http_status(200) }
      it { expect(flash[:notice]).to be_nil }
    end

  end
end
