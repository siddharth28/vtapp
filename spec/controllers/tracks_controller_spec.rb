require 'rails_helper'

describe TracksController do
  let(:current_user) { mock_model(User) }
  let(:track) { mock_model(Track)}
  let(:company) { mock_model(Company)}
  let(:ability) { double(Ability) }
  let(:tracks) { double(ActiveRecord::Relation) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(current_user).to receive(:has_role?).and_return(true)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#create' do
    before do
      allow(Track).to receive(:new).with(name: 'Test Track').and_return(track)
      allow(current_user).to receive(:company).and_return(company)
      allow(company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:build).and_return(track)
      allow(track).to receive(:save).and_return(true)
    end

    def send_request
      post :create, track: { name: 'Test Track' }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(Track).to receive(:new).with(name: 'Test Track').and_return(track) }
      it { expect(current_user).to receive(:company).and_return(company) }
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
    def send_request
      get :index
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response.body).to be_blank }
    end
  end

  describe '#track_params' do
    before do
      allow(Track).to receive(:new).with({ name: 'Test Track', owner_name: 'Owner', owner_email: 'Email@email.com', enabled: false }.with_indifferent_access).and_return(track)
      allow(current_user).to receive(:company).and_return(company)
      allow(company).to receive(:tracks).and_return(tracks)
      allow(tracks).to receive(:build).and_return(track)
      allow(track).to receive(:save).and_return(true)
    end

    def send_request
      post :create, track: { name: 'Test Track', owner_name: 'Owner', owner_email: 'Email@email.com', enabled: false }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(Track).to receive(:new).with({ name: 'Test Track', owner_name: 'Owner', owner_email: 'Email@email.com', enabled: false }.with_indifferent_access).and_return(track) }
    end
  end
end
