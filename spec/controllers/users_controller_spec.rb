require 'rails_helper'

describe UsersController do
  describe '#show' do
    let(:user) { mock_model(User) }

    before do
      allow(User).to receive(:find).and_return(user)
    end

    def send_request
      get :show, { user: { name: 'Test User' }, id: 122 }
    end

    describe 'expects to send' do
      after do
        send_request
      end

      it { expect(User).to receive(:find).and_return(user) }
    end

    describe 'assigns' do
      before do
        send_request
      end

      it { expect(assigns(:user)).to eq(user) }
    end

    describe 'response' do
      before do
        send_request
      end

      it { expect(response).to render_template 'users/show' }
    end
  end

end
