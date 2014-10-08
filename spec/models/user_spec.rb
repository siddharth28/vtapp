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

    #FIXED
    #FIXME Also check password_confirmation and both password and password_confirmation should be equal
    describe 'before validation' do
      it { expect { user.valid? }.to change{ user.password.nil? }.from(true).to(false) }
    end

    #FIXED
   #FIXME Write rspec when neither super_admin nor account_owner
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

    #FIXED
    #FIXME Write rspec when user is not super_admin
    context 'either super_admin or account_owner' do
      describe '#super_admin?' do
        before { user.add_role(:super_admin) }
        it { expect(user.super_admin?).to eql(true) }
      end
      #FIXED
      #FIXME Write rspec when user is not super_admin
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

    #FIXME Write rspecs for more conditions.
    describe '#active_for_authentication?' do
      context 'when super_admin' do
        before { user.add_role(:super_admin) }
        it { expect(user.active_for_authentication?).to eql(true) }
      end

      context 'not super_admin' do
        let(:user) { company.users.build({ name: 'Vinsol', enabled: true } ) }
        before do
          user.add_role(:account_owner)
          company.toggle!(:enabled)
        end

        it { expect(user.active_for_authentication?).to eql(false) }
      end
    end

    #FIXED
    #FIXME It is not required
    describe '#send_password_email' do
      before do
        user.send(:set_random_password)
        password_length = user.password.length
        password_confirmation_length = user.password_confirmation.length
      end

      it { expect (password_length).to eq(password_confirmation_length) }
    end

    describe '#send_password_email' do
      it { expect { user.send(:send_password_email) }.to change{Delayed::Backend::ActiveRecord::Job.count}.by(1) }
    end
  end

  #FIXED
  #FIXME Check users with account_role should be returned.
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
