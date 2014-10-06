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
    it { expect { user.mentor_id = 890 }.to change{ user.valid? }.from(true).to(false) }
  end

  describe 'callbacks' do
    let(:user) { build(:user, name: nil, email: nil, password: nil) }

    describe 'before validation' do
      it { expect { user.valid? }.to change{ user.password.nil? }.from(true).to(false) }
    end
  end

  describe 'attributes' do
    it { expect(user).to respond_to(:email) }
    it { expect(user).to respond_to(:company_id) }

    describe 'readonly_attributes' do
      it { should have_readonly_attribute(:email) }
      it { should have_readonly_attribute(:company_id) }
    end
  end

  describe 'instance methods' do
    let(:user) { build(:user, name: nil, email: nil, password: nil) }
    let(:company) { build(:company, name: 'Vinsol', enabled: true ) }

    it { expect(user).not_to respond_to(:set_random_password) }
    it { expect(user).not_to respond_to(:send_password_email) }
    it { expect(user).to respond_to(:active_for_authentication?) }

    describe '#active_for_authentication?' do
      context 'user super_admin' do
        it 'super_admin' do
          user.add_role 'super_admin'
          expect(user.active_for_authentication?).to eql(true)
        end
      end

      context 'user not super_admin' do
        before do
          user.add_role 'account_owner'
          company.toggle!(:enabled)
        end
        let(:user) { company.users.build({ name: 'Vinsol', enabled: true } ) }
        # FIXED
        ## FIXME_NISH refactor this spec
        it { expect(user.active_for_authentication?).to eql(false) }
      end
    end

    describe '#set_random_password' do
      it { expect { user.send(:set_random_password) }.to change{ user.password.nil? }.from(true).to(false) }
    end
  end
end
