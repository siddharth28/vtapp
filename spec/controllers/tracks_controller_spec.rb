require 'rails_helper'

describe TracksController do
  let(:current_company) { mock_model(Company) }
  let(:track) { mock_model(Track)}
  let(:company) { mock_model(Company)}
  let(:ability) { double(Ability) }
  let(:tracks) { double(ActiveRecord::Relation) }
  let(:user) { mock_model(User) }
  let(:role) { mock_model(Role) }


  before do
    allow(controller).to receive(:current_company).and_return(current_company)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
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

  describe '#index' do
    before do
      allow(current_company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:load_with_owners).and_return(tracks)
      allow(tracks).to receive(:page).with(nil).and_return(tracks)
      allow(tracks).to receive(:per).with(20).and_return(tracks)
    end

    def send_request
      get :index, { page: nil }
    end

    describe 'expects to receive' do
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

  describe '#update' do
    before do
      allow(Track).to receive(:find).and_return(track)
      allow(track).to receive(:update).and_return(true)
      allow(track).to receive(:owner).and_return(user)
      allow(track).to receive(:remove_track_role).with(:track_owner, user).and_return(role)
      allow(track).to receive(:add_track_role).with(:track_owner, '4').and_return(role)
    end

    def send_request
      patch :update, track: { name: "Rails", description: "a", instructions: "b", references: "c", owner: "tanmay+1@vinsol.com", owner_id: "4" }, id: track
    end

    describe 'expects to receive' do
      it { expect(Track).to receive(:find).and_return(track) }
      it { expect(track).to receive(:update).and_return(true) }
      it { expect(track).to receive(:owner).and_return(user) }
      it { expect(track).to receive(:remove_track_role).with(:track_owner, user).and_return(role) }
      it { expect(track).to receive(:add_track_role).with(:track_owner, '4').and_return(role) }

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
      context 'reviewer_id not blank' do
        before { send_request }
        it { expect(response).to have_http_status(200) }
        it { expect(response).to render_template 'tracks/assign_reviewer' }
      end

      context 'reviewer_id blank' do
        before do
          xhr :patch, :assign_reviewer, track: { reviewer_name: 'abc', reviewer_id: "" }, id: track.id, format: :js
        end

        it { expect(track.errors[:reviewer_name]).to eq(["can't be blank"]) }
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
      allow(tracks).to receive(:extract).with('Owner', nil).and_return(tracks)
      allow(tracks).to receive(:search).with('example').and_return(tracks)
      allow(tracks).to receive(:result).and_return(tracks)
      allow(tracks).to receive(:page).with(nil).and_return(tracks)
      allow(tracks).to receive(:per).with(20).and_return(tracks)
    end

    def send_request
      get :search, { type: 'Owner', q: 'example',  page: nil }
    end

    describe 'expects to receive' do
      it{ expect(current_company).to receive(:tracks).and_return(tracks) }
      it{ expect(tracks).to receive(:load_with_owners).and_return(tracks) }
      it{ expect(tracks).to receive(:extract).with('Owner', nil).and_return(tracks) }
      it{ expect(tracks).to receive(:search).with('example').and_return(tracks) }
      it{ expect(tracks).to receive(:result).and_return(tracks) }
      it{ expect(tracks).to receive(:page).with(nil).and_return(tracks) }
      it{ expect(tracks).to receive(:per).with(20).and_return(tracks) }

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
end
