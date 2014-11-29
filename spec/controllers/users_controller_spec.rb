require 'rails_helper'

describe UsersController do
  let(:user) { mock_model(User) }
  let(:company) { mock_model(Company) }
  let(:current_user) { mock_model(User) }
  let(:users) { double(ActiveRecord::Relation) }
  let(:ability) { double(Ability) }
  let(:usertasks) { double(ActiveRecord::Relation) }
  let(:usertask) { mock_model(Usertask) }

  def sign_in(user)
    if user.nil?
      allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, { scope: :user })
      allow(controller).to receive(:current_user).and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end

  before do
    sign_in(user)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:authorize!).and_return(true)
    allow(ability).to receive(:attributes_for).and_return([])
    allow(ability).to receive(:has_block?).and_return(true)
  end

  describe '#index' do
    before do
      allow(user).to receive(:company).and_return(company)
      allow(company).to receive(:users).and_return(users)
      allow(users).to receive(:includes).with(:roles, :company).and_return(users)
      allow(users).to receive(:search).with({ s: "name asc" }).and_return(users)
      allow(users).to receive(:result).and_return(users)
      allow(users).to receive(:page).with(nil).and_return(users)
    end

    def send_request
      get :index
    end

    describe 'expects to receive' do
      it { expect(user).to receive(:company).and_return(company) }
      it { expect(company).to receive(:users).and_return(users) }
      it { expect(users).to receive(:includes).with(:roles, :company).and_return(users) }
      it { expect(users).to receive(:search).with({ s: "name asc" }).and_return(users) }
      it { expect(users).to receive(:result).and_return(users) }
      it { expect(users).to receive(:page).with(nil).and_return(users) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:search)).to eq(users) }
      it { expect(assigns(:users)).to eq(users) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template :index }
    end
  end

  describe '#create' do
    before do
      allow(controller).to receive(:user_params)
      allow(user).to receive(:company).and_return(company)
      allow(user).to receive(:account_owner?).and_return(true)
      allow(company).to receive(:users).and_return(users)
      allow(users).to receive(:build).and_return(user)
      allow(user).to receive(:save).and_return(true)
      allow(controller).to receive(:remove_empty_element_multiple_select)
      allow(user).to receive(:add_role_account_admin)
      allow(user).to receive(:remove_role_account_admin)
    end

    context 'account_admin true' do

      def send_request
        post :create, user: { name: 'Test User', email: 'test_email@email.com' }, account_admin?: true
      end

      describe 'expects to send' do
        it { expect(controller).to receive(:remove_empty_element_multiple_select) }
        it { expect(controller).to receive(:user_params) }
        it { expect(user).to receive(:company).and_return(company) }
        it { expect(company).to receive(:users).and_return(users) }
        it { expect(users).to receive(:build).and_return(user) }
        it { expect(user).to receive(:save).and_return(true) }
        it { expect(controller).to receive(:add_or_remove_role_account_admin) }
        it { expect(user).to receive(:add_role_account_admin) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:user)).to eq(user) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to user_path(user) }
          it { expect(response).to have_http_status(302) }
          it { expect(flash[:notice]).to eq("User #{ user.name } is successfully created.") }
        end

        context "when user cannot be created" do
          before do
            allow(user).to receive(:save).and_return(false)
            send_request
          end

          it { expect(response).to render_template :new }
          it { expect(response).to have_http_status(200) }
          it { expect(flash[:notice]).to be_nil }
        end
      end
    end

    context 'account_admin false' do

      def send_request
        post :create, user: { name: 'Test User', email: 'test_email@email.com' }, account_admin?: false
      end

      describe 'expects to send' do
        it { expect(controller).to receive(:remove_empty_element_multiple_select) }
        it { expect(controller).to receive(:user_params) }
        it { expect(user).to receive(:company).and_return(company) }
        it { expect(company).to receive(:users).and_return(users) }
        it { expect(users).to receive(:build).and_return(user) }
        it { expect(user).to receive(:save).and_return(true) }
        it { expect(controller).to receive(:add_or_remove_role_account_admin) }
        it { expect(user).to receive(:remove_role_account_admin) }

        after { send_request }
      end

      describe 'assigns' do
        before { send_request }
        it { expect(assigns(:user)).to eq(user) }
      end

      describe 'response' do
        context "when response is successfully created" do
          before { send_request }
          it { expect(response).to redirect_to user_path(user) }
          it { expect(response).to have_http_status(302) }
          it { expect(flash[:notice]).to eq("User #{ user.name } is successfully created.") }
        end

        context "when user cannot be created" do
          before do
            allow(user).to receive(:save).and_return(false)
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
    before do
      allow(controller).to receive(:remove_empty_element_multiple_select)
      allow(controller).to receive(:add_or_remove_role_account_admin)
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:company).and_return(company)
      allow(user).to receive(:update).and_return(true)
      allow(user).to receive(:account_owner?).and_return(true)
    end

    def send_request
      patch :update, id: user, user: { name: 'Test User', email: 'test_email@email.com' }
    end

    describe 'expects to send' do
      it { expect(User).to receive(:find).and_return(user) }
      it { expect(user).to receive(:update).and_return(true) }
      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:user)).to eq(user) }
    end

    describe 'response' do
      context "when response is successfully created" do
        before { send_request }
        it { expect(response).to redirect_to user_path(user) }
        it { expect(response).to have_http_status(302) }
        it { expect(flash[:notice]).to eq("User #{ user.name } is successfully updated.") }
      end

      context "when user cannot be updated" do
        before do
          allow(user).to receive(:update).and_return(false)
          send_request
        end

        it { expect(response).to render_template :edit }
        it { expect(response).to have_http_status(200) }
        it { expect(flash[:notice]).to be_nil }
      end
    end
  end

  describe '#mentees' do
    before do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:mentees).and_return(users)
      allow(users).to receive(:includes).with(:roles, :company).and_return(users)
      allow(users).to receive(:search).with({ s: "name asc" }).and_return(users)
      allow(users).to receive(:result).and_return(users)
      allow(users).to receive(:page).with(nil).and_return(users)
    end

    def send_request
      get :mentees, id: user.id
    end

    describe 'expects to receive' do
      it { expect(user).to receive(:mentees).and_return(users) }
      it { expect(users).to receive(:includes).with(:roles, :company).and_return(users) }
      it { expect(users).to receive(:search).with({ s: "name asc" }).and_return(users) }
      it { expect(users).to receive(:result).and_return(users) }
      it { expect(users).to receive(:page).with(nil).and_return(users) }

      after { send_request }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:search)).to eq(users) }
      it { expect(assigns(:mentees)).to eq(users) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
      it { expect(response).to render_template :mentees }
    end
  end

end
