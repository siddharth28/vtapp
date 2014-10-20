require 'rails_helper'

describe TracksController do
  let(:current_user) { mock_model(User) }
  let(:track) { mock_model(Track)}
  let(:company) { mock_model(Company)}
  let(:ability) { double(Ability) }
  let(:tracks) { double(ActiveRecord::Relation) }
  let(:user) { mock_model(User) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(current_user).to receive(:has_role?).and_return(true)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#create' do
    before do
      allow(controller).to receive(:set_company).and_return(company)
      allow(Track).to receive(:new).with(name: 'Test Track').and_return(track)
      allow(company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:build).and_return(track)
      allow(track).to receive(:save).and_return(true)
    end

    def send_request
      post :create, track: { name: 'Test Track' }
    end

    describe 'expects to send' do
      after { send_request }
      # example for #set_company
      it { expect(controller).to receive(:set_company).and_return(company) }
      it { expect(Track).to receive(:new).with(name: 'Test Track').and_return(track) }
      it { expect(company).to receive(:tracks).and_return(tracks) }
      it { expect(tracks).to receive(:build).and_return(track) }
      it { expect(track).to receive(:save).and_return(true) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to tracks_path(company: company) }
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
      allow(current_user).to receive(:company).and_return(company)
      allow(company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:search).with('example').and_return(tracks)
      allow(tracks).to receive(:result).and_return(tracks)
      allow(tracks).to receive(:page).with(nil).and_return(tracks)
      allow(tracks).to receive(:per).with(20).and_return(tracks)
    end

    def send_request
      get :index, { q: 'example', page: nil }
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(current_user).to receive(:company).and_return(company) }
      it { expect(company).to receive(:tracks).and_return(tracks) }
      it { expect(tracks).to receive(:search).with('example').and_return(tracks) }
      it { expect(tracks).to receive(:result).and_return(tracks) }
      it { expect(tracks).to receive(:page).with(nil).and_return(tracks) }
      it { expect(tracks).to receive(:per).with(20).and_return(tracks) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:search)).to eq(tracks) }
      it { expect(assigns(:tracks)).to eq(tracks) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response.body).to be_blank }
    end
  end

  describe '#reviewers' do
    before do
      allow(controller).to receive(:set_data).and_return([company, track])
      allow(controller).to receive(:set_track).and_return(track)
      allow(Track).to receive(:find).and_return(track)
    end

    def send_request
      get :reviewers, { id: track.id }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:company)).to eq(company) }
      it { expect(assigns(:track)).to eq(track) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template :reviewers }
    end
  end

  describe '#toggle_enabled' do
    before do
      allow(Track).to receive(:find).and_return(track)
      allow(track).to receive(:toggle!).and_return(true)
    end

    def send_request
      xhr :patch, :toggle_enabled, id: track.id
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(track).to receive(:toggle!).and_return(true) }
    end

    describe 'response' do
      before { send_request }

      it { expect(response).to render_template :toggle_enabled }
      it { expect(response).to have_http_status(200) }
    end
  end


  describe '#assign_reviewer' do
    before do
      allow(controller).to receive(:set_data).and_return([company, track])
      allow(controller).to receive(:set_track).and_return(track)
      allow(Track).to receive(:find).and_return(track)
      allow(track).to receive(:add_reviewer).with("123").and_return(user)
    end

    def send_request
      xhr :patch, :assign_reviewer, track: { reviewer_name: 'abc', reviewer_id: "123" }, id: track.id, format: :js
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(track).to receive(:add_reviewer).with("123").and_return(true) }
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

  describe '#remove_reviewer' do
    before do
      allow(controller).to receive(:set_data).and_return([company, track])
      allow(controller).to receive(:set_track).and_return(track)
      allow(Track).to receive(:find).and_return(track)
      allow(track).to receive(:remove_reviewer).with("123").and_return(user)
    end

    def send_request
      xhr :get, :remove_reviewer, { format: "123", id: track.id }, format: :js
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(track).to receive(:remove_reviewer).with("123").and_return(true) }
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

  describe '#set_company' do
    before do
      allow(current_user).to receive(:company).and_return(company)
    end

    it { expect(controller.send(:set_company)).to eql(company) }
  end

  describe '#set_track' do
    before do
      allow(current_user).to receive(:company).and_return(company)
      allow(company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:find_by).and_return(track)
    end

    it { expect(controller.send(:set_track, company)).to eql(track) }
  end

  describe '#set_data' do
    before do
      allow(current_user).to receive(:company).and_return(company)
      allow(company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:find_by).and_return(track)
    end

    it { expect(controller.send(:set_data)).to eql([company, track]) }
  end

  describe '#track_params' do
    before do
      allow(Track).to receive(:new).with({ name: 'Test Track', description: 'Owner', instructions: 'Abcd', references: 'ABCD', enabled: false }.with_indifferent_access).and_return(track)
      allow(current_user).to receive(:company).and_return(company)
      allow(company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:build).and_return(track)
      allow(track).to receive(:save).and_return(true)
    end

    def send_request
      post :create, track: { name: 'Test Track', description: 'Owner', instructions: 'Abcd', references: 'ABCD', enabled: false, status: true }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(Track).to receive(:new).with({ name: 'Test Track', description: 'Owner', instructions: 'Abcd', references: 'ABCD', enabled: false }.with_indifferent_access).and_return(track) }
    end
  end
end
