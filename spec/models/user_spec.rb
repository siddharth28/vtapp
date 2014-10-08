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
      it { should belong_to(:mentor) }
    end
  end

  describe 'validation' do
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:name) }
    it { expect { user.mentor_id = 890 }.to change{ user.valid? }.from(true).to(false) }
  end

  describe 'callbacks' do
    let(:company) { create(:company) }
    let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }

    describe 'before validation' do
      it { expect { user.valid? }.to change{ user.password.nil? }.from(true).to(false) }
    end

    describe 'before destroy' do
      context ' when super_admin' do
        before do
          user.add_role(:super_admin)
        end

        it { expect { user.destroy }.to raise_error }
      end

      context ' when account_owner' do
        before do
          allow(company).to receive(:owner).and_return(false)
          user.add_role(:account_owner)
        end

        it { expect { user.destroy }.to raise_error }
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

    describe '#super_admin?' do
      before do
        user.add_role(:super_admin)
      end

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

    describe '#active_for_authentication?' do
      context ' when super_admin' do
        before do
          user.add_role(:super_admin)
        end

        it { expect(user.active_for_authentication?).to eql(true) }
      end

      context 'user not super_admin' do
        let(:user) { company.users.build({ name: 'Vinsol', enabled: true } ) }
        before do
          user.add_role(:account_owner)
          company.toggle!(:enabled)
        end
        # FIXED
        ## FIXME_NISH refactor this spec
        it { expect(user.active_for_authentication?).to eql(false) }
      end
    end

    describe '#set_random_password' do
      it { expect { user.send(:set_random_password) }.to change{ user.password.nil? }.from(true).to(false) }
    end
  end

  describe 'scope' do
    let(:company) { create(:company) }
    let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }

    describe '#with_account_owner_role' do
      before do
        allow(company).to receive(:owner).and_return(false)
        user.add_role 'account_owner'
        user.save
      end
      it { expect(User.with_account_owner_role).not_to be_nil }
    end
  end
end
