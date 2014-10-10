require 'rails_helper'

describe User do
  let(:company) { create(:company) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { build(:user, mentor_id: mentor.id, company: company) }

  describe 'associations' do
    describe 'has_many association' do
      it { should have_many(:mentees).with_foreign_key(:mentor_id).dependent(:nullify) }
    end

    describe 'belongs_to' do
      it { should belong_to(:company) }
      #FIXME check class_name also
      it { should belong_to(:mentor) }
    end
  end

  describe 'validation' do
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:name) }

    context 'not present' do
      let(:user) { build(:user) }
      before { user.add_role(:track_owner) }
      it { expect(user.valid?).to eql(false) }
    end

    #FIXME Change rspec as discussed.
    context 'mentor not present' do
      it { expect { user.mentor_id = 890 }.to change{ user.valid? }.from(true).to(false) }
    end

    context 'mentor present' do
      before { user.mentor_id = 890 }
      it { expect { user.mentor_id = mentor.id }.to change{ user.valid? }.from(false).to(true) }
    end
  end

  describe 'callbacks' do
    let(:company) { create(:company) }
    let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }

    #FIXME Change as discussed.
    describe 'before validation' do
      it { expect { user.valid? }.to change{ user.password.nil? }.from(true).to(false) }
    end

    #FIXME Write method name also in describe block. Check error_messages also.
    describe 'before destroy' do
      context 'when super_admin' do
        before { user.add_role(:super_admin) }
        it { expect { user.destroy }.to raise_error }
      end

      context 'when account_owner' do
        before do
          allow(company).to receive(:owner).and_return(false)
          user.save
          user.add_role(:account_owner)
        end

        it { expect { user.destroy }.to raise_error }
      end

      context 'neither super_admin nor account_owner' do
        before { user.add_role(:track_owner) }
        it { expect { user.destroy }.not_to raise_error }
      end
    end
  end

  describe 'attributes' do
    describe 'readonly_attributes' do
      it { should have_readonly_attribute(:email) }
      it { should have_readonly_attribute(:company_id) }
    end
  end

  describe 'instance methods' do
    let(:user) { build(:user, name: nil, email: nil, password: nil) }
    let(:company) { build(:company, name: 'Vinsol', enabled: true ) }

    #FIXME Change as discussed
    context 'either super_admin or account_owner' do
      describe '#super_admin?' do
        before { user.add_role(:super_admin) }
        it { expect(user.super_admin?).to eql(true) }
      end

      describe '#account_owner?' do
        let(:company) { create(:company) }
        let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }

        before do
          allow(company).to receive(:owner).and_return(false)
          user.add_role(:account_owner)
        end

        it { expect(user.account_owner?).to eql(true) }
      end
    end

    context 'neither super_admin nor account_owner' do
      describe '#super_admin?' do
        before { user.add_role(:track_owner) }
        it { expect(user.super_admin?).to eql(false) }
        it { expect(user.account_owner?).to eql(false) }
      end
    end

    describe '#active_for_authentication?' do
      #FIXME Wrong test case. Change as discussed.
      context 'when super_admin' do
        before { user.add_role(:super_admin) }
        it { expect(user.active_for_authentication?).to eql(true) }
      end

      context 'not super_admin' do
        let(:user) { company.users.build({ name: 'Vinsol', enabled: true } ) }
        before do
          user.add_role(:track_owner)
        end

        def status(company, state1, state2)
          enabled = state1
          company.enabled = state2
        end

        context 'disabled, company_enabled' do
          before { status(company, false, true) }
          it { expect(user.active_for_authentication?).to eql(true) }
        end

        context 'enabled, company_enabled' do
          before { status(company, true, true) }
          it { expect(user.active_for_authentication?).to eql(true) }
        end

        context 'enabled, company_disabled' do
          before { status(company, true, false) }
          it { expect(user.active_for_authentication?).to eql(false) }
        end

        context 'disabled, company_disabled' do
          before { status(company, false, false) }
          it { expect(user.active_for_authentication?).to eql(false) }
        end
      end

    end

    describe '#set_random_password' do
      before do
        user.send(:set_random_password)
      end

      it { expect(user.password).to eq(user.password_confirmation) }
    end

    #FIXME Change as discussed.
    describe '#send_password_email' do
      it { expect { user.send(:send_password_email) }.to change{Delayed::Backend::ActiveRecord::Job.count}.by(1) }
    end

    #FIXME Check error_message also
    describe '#ensure_only_one_account_owner' do
      it { expect { user.add_role(:account_owner) }.to raise_error }
    end

    #FIXME Check error_message also
    describe 'ensure_cannot_remove_account_owner_role' do
      let(:company) { create(:company) }
      let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }
      it { expect { company.owner.destroy }.to raise_error }
    end
  end

  describe 'scope' do
    let(:company) { create(:company) }
    let(:user) { build(:user, company: company) }
    let(:user1) { create(:user, company: company) }

    describe '#with_account_owner_role' do
      before do
        allow(company).to receive(:owner).and_return(false)
        user.add_role 'account_owner'
        user1.add_role 'super_admin'
        user.save
      end
      it { expect(User.with_account_owner_role.all? { |user| user.has_role?(:account_owner)}).to eq(true) }
    end
  end
end
