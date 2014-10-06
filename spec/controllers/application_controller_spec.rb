require 'rails_helper'

describe ApplicationController do
  controller(ApplicationController) do
    def index
      redirect_to after_sign_in_path_for(User.new)
    end
  end

  describe 'instance methods' do
    def send_request
      get :index
    end

    describe '#after_sign_in_path_for' do
      before do
        send_request
      end

      it { expect(response).to have_http_status(302) }
      it { expect(response).to redirect_to '/companies' }
    end
  end
end
