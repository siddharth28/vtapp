require 'rails_helper'

describe UsersController do
  let(:user) { mock_model(User) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }

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
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:has_role?).and_return(true)
      allow(controller).to receive(:authenticate_user!)
    end

    def send_request
      get :show, { user: { name: 'Test User' }, id: user.id }
    end

    describe 'expects to send' do
      after { send_request }
      it { expect(User).to receive(:find).and_return(user) }
      it { expect(controller).to receive(:authenticate_user!) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:user)).to eq(user) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to render_template 'users/show' }
    end
  end
end
