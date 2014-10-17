require 'rails_helper'

describe User do
  let(:company) { create(:company) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { build(:user, mentor_id: mentor.id, company: company) }

  #FIXME -> Check constant value.
  describe 'constants' do
    it { User.should have_constant(:ROLES) }
  end

  describe 'associations' do
    #FIXME -> Check class_name also
    describe 'has_many association' do
      it { should have_many(:mentees).with_foreign_key(:mentor_id).dependent(:restrict_with_error) }
    end

    describe 'belongs_to' do
      it { should belong_to(:company) }
      
      #FIXME To check class_name there is a should_a matcher.
      it { should belong_to(:mentor) }
      describe 'class_name in belongs_to mentor' do
        it { expect(mentor.class).to eql(User) }
      end
    end
  end

  describe 'validation' do
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:name) }

    #FIXME -> Why this context ?
    context 'not present' do
      let(:user) { build(:user) }
      before { user.add_role(:track_owner) }
      it { expect(user.valid?).to eql(false) }
    end
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

      #FIXME -> Also check error message.
      context 'invalid mentor present' do
        let(:user) { build(:user, mentor_id: 3920220, company: company) }
        it { expect { user.valid? }.to change{ user.errors[:mentor].present? }.from(false).to(true) }
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
    describe 'after_create #make_admin' do
      let(:user) { build(:user, company: company)}
      context 'is admin' do
        before { user.admin = true }
        it { expect(user).to receive(:make_admin) }
        after { user.save! }
      end
      context 'not an admin' do
        before { user.admin = false }
        it { expect(user).not_to receive(:make_admin) }
        after { user.save! }
      end
      describe '#make_admin' do
        before do
          user.admin = true
          user.save
        end
        it { expect(user.has_role? :account_admin).to eql(true) }
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
      it { expect(delayed_job).to receive(:welcome_email).and_return(delayed_job) }
      after { user.send(:send_password_email) }
    end

    describe '#ensure_only_one_account_owner' do
      let(:user) { create(:user, company: company) }
      it { expect { user.add_role(:account_owner) }.to raise_error("There can be only one account owner") }
    end

    #FIXED
    #FIXME Check error_message also
    describe '#ensure_cannot_remove_account_owner_role' do
      let(:company) { create(:company) }
      it { expect { company.owner.first.remove_role :account_owner }.to raise_error('Cannot remove account_owner role') }
    end

    describe '#display_user_details' do
      it { expect(user.send(:display_user_details)).to eql("#{ user.name } :#{ user.email }") }
    end
  end
end
