require 'rails_helper'

describe User do
  let(:user) { build(:user) }

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
    context 'mentor present' do
      before do
        user.mentor_id = 1
        user.save
      end
      # FIXED
      ## FIXME_NISH Please write only one or two line in spec, move the rest of code in before of this context.
      it { should validate_presence_of(:mentor) }
    end
  end

  context 'mentor not present' do
    it { should_not validate_presence_of(:mentor) }
  end


  describe 'callbacks' do
    let(:user) { build(:user, name: nil, email: nil, password: nil) }

    describe 'before validation' do
      it { expect { user.valid? }.to change{ user.password.nil? }.from(true).to(false) }
    end

    # describe 'after commit' do
    #   after { run_callbacks(:commit) }
    #   it { should_receive(:Mail) }
    # end
  end

  describe 'attributes' do
    it { expect(user).to respond_to(:email) }
    it { expect(user).to respond_to(:company_id) }

    describe 'readonly_attributes' do
      it 'should not update readonly attribute email' do
        user.update_attributes email: 'new_test@example.com'
        expect(user.reload.email).to eql user.email
      end

      it 'should not update readonly attribute company_id' do
        user.update_attributes company_id: 1
        expect(user.reload.company_id).to eql user.company_id
      end
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


        ## FIXME_NISH refactor this spec
        it { expect(user.active_for_authentication?).to eql(false) }
      end
    end


    describe '#set_random_password' do
      it { expect { user.send(:set_random_password) }.to change{ user.password.nil? }.from(true).to(false) }
    end
  end
  # describe '#send_password_email' do
  #   it { expect { user.send(:set_random_password) }.to change{ user.password.nil? }.from(true).to(false) }
  # end


  describe 'scope' do
    describe 'owner' do
      before do
        user.add_role 'account_owner'
        user.save
      end
      it 'account_owner' do
        expect(User.owner.first.has_role? :account_owner).to eql(true)
      end
      # FIXED
      ##FIXME_NISH remove the trailing space.
    end
  end
end
