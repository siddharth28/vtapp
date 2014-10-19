require 'rails_helper'

describe User do
  let(:company) { create(:company) }
  let(:mentor) { build(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { build(:user, mentor_id: mentor.id, company: company) }
  #FIXED
  #FIXME -> Check constant value.
  describe 'constants' do
    it { User.should have_constant(:ROLES) }
    it { expect(User::ROLES[:super_admin]).to eql('super_admin') }
    it { expect(User::ROLES[:account_owner]).to eql('account_owner') }
    it { expect(User::ROLES[:account_admin]).to eql('account_admin') }
  end

  describe 'associations' do
    #FIXED
    #FIXME -> Check class_name also
    describe 'has_many association' do
      it { should have_many(:mentees).class_name(User).with_foreign_key(:mentor_id).dependent(:restrict_with_error) }
      it { should have_many(:tracks).through(:roles).source(:resource) }
    end

    describe 'belongs_to' do
      it { should belong_to(:company) }
      #FIXED
      #FIXME To check class_name there is a should_a matcher.
      it { should belong_to(:mentor).class_name(User) }
    end
  end

  describe 'validation' do
    it { should validate_presence_of(:company) }
    context 'user is a super_admin' do
      let(:user) { build(:user) }

      before { user.add_role(:super_admin) }

      it { expect(user.valid?).to eql(true) }
    end
    it { should validate_presence_of(:name) }
    #FIXED
    #FIXME -> Why this context ?
    #FIXED
    #FIXME Change rspec as discussed.

    describe 'mentor validation' do

      context 'mentor not present' do
        it { should_not validate_presence_of(:mentor) }
      end

      context 'valid mentor present' do
        let(:user) { build(:user, mentor_id: mentor.id, company: company) }

        it { expect(user.valid?).to eql(true) }
      end
      #FIXED
      #FIXME -> Also check error message.
      context 'invalid mentor present' do
        let(:user) { build(:user, mentor_id: 3920220, company: company) }

        before { user.valid? }

        it { expect(user.errors[:mentor].include?("can't be blank")).to eql(true) }
      end

    end
  end

  describe 'callbacks' do
    let(:company) { create(:company) }
    let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }
    #FIXED
    #FIXME Change as discussed.
    describe 'before validation#set_random_password' do

      it do
        expect { user.valid? }.to change{ user.password.nil? }.from(true).to(false)
        expect(user.password).to eq(user.password_confirmation)
      end

    end

    describe 'before destroy#ensure_an_account_owners_and_super_admin_remains' do
      context 'when super_admin' do
        before { user.add_role(:super_admin) }

        it { expect { user.destroy }.to raise_error("Can't delete Super Admin") }
      end

      context 'when account_owner' do
        it { expect { company.owner.first.destroy }.to raise_error("Can't delete Account Owner") }
      end

      context 'neither super_admin nor account_owner' do
        before { user.add_role(:track_owner) }

        it { expect { user.destroy }.not_to raise_error }
      end
    end
    describe 'after_save #add_or_remove_admin_role' do
      let(:user) { build(:user, company: company) }

      context 'is admin' do
        before { user.admin = true }

        it { expect(user).to receive(:add_or_remove_admin_role) }

        after { user.save }
      end
      context 'not an admin' do
        before { user.admin = false }

        it { expect(user).to receive(:add_or_remove_admin_role) }
        it { expect(user.account_admin?).to eql(false)}

        after { user.save }
      end
    end

    describe 'after_initialize#set_admin' do

      let(:user) { create(:user, company: company) }

      context 'when admin' do
        before do
          user.add_role(:account_admin, user.company)
        end

        it { expect(User.find_by(id: user.id).admin).to eql(true) }
      end

      context 'when not an admin' do
        it { expect(User.find_by(id: user.id).admin).to eql(false) }
      end

    end

  end

  describe 'instance methods' do
    let(:user) { build(:user, name: nil, email: nil, password: nil) }
    let(:company) { build(:company, name: 'Vinsol', enabled: true ) }

    describe '#super_admin?' do

      context 'is a super_admin' do
        before { user.add_role(:super_admin) }

        it { expect(user.super_admin?).to eql(true) }
      end

      context 'not a super_admin' do
        it { expect(user.super_admin?).to eql(false) }
      end
    end

    describe '#account_owner?' do
      context 'is an account_owner' do
        let(:company) { create(:company) }
        let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }

        it { expect(company.owner.first.account_owner?).to eql(true) }
      end
      context 'not an account_owner' do
        it { expect(user.account_owner?).to eql(false) }
      end
    end

    describe '#account_admin?' do
      context 'is an account_admin' do
        before { user.add_role(:account_admin) }

        it { expect(user.account_admin?).to eql(true) }
      end

      context 'not an account_admin' do
        it { expect(user.account_admin?).to eql(false) }
      end
    end

    describe '#active_for_authentication?' do
      context 'when super_admin' do
        before { user.add_role(:super_admin) }

        it { expect(user.active_for_authentication?).to eql(true) }
      end

      context 'not super_admin' do
        let(:user) { company.users.build({ name: 'Vinsol', enabled: true } ) }

        def status(user, state1, state2)
          user.enabled = state1
          user.company.enabled = state2
        end

        context 'company_enabled' do

          context 'user_disabled' do
            before { status(user, false, true) }

            it { expect(user.active_for_authentication?).to eql(false) }
          end

          context 'user_enabled' do
            before { status(user, true, true) }

            it { expect(user.active_for_authentication?).to eql(true) }
          end
        end
        context 'company_disabled' do
          context 'user_enabled' do
            before { status(user, true, false) }

            it { expect(user.active_for_authentication?).to eql(false) }
          end

          context 'user_disabled' do
            before { status(user, false, false) }

            it { expect(user.active_for_authentication?).to eql(false) }
          end
        end
      end
    end

    #FIXED
    #FIXME Change as discussed.
    describe '#send_password_email' do
      let(:user) { build(:user) }
      let(:delayed_job) { mock_model(Delayed::Backend::ActiveRecord::Job) }

      before do
        allow(UserMailer).to receive(:delay).and_return(delayed_job)
        allow(delayed_job).to receive(:welcome_email).and_return(delayed_job)
      end

      it { expect(UserMailer).to receive(:delay).and_return(delayed_job) }
      #FIXME -> Test with arguments
      it { expect(delayed_job).to receive(:welcome_email).with(user.email, user.password).and_return(delayed_job) }

      after { user.send(:send_password_email) }
    end

    describe '#ensure_only_one_account_owner' do
      let(:user) { create(:user, company: company) }

      it { expect { user.add_role(:account_owner, company) }.to raise_error("There can be only one account owner") }
    end

    #FIXED
    #FIXME Check error_message also
    describe '#ensure_cannot_remove_account_owner_role' do
      let(:company) { create(:company) }

      it { expect { company.owner.first.remove_role :account_owner, company }.to raise_error('Cannot remove account_owner role') }
    end

    describe '#display_user_details' do
      it { expect(user.send(:display_user_details)).to eql("#{ user.name } : #{ user.email }") }
    end
  end
end
