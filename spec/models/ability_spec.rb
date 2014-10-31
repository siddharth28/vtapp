require 'cancan/matchers'
require 'rails_helper'

describe Ability do

  let(:company) { create(:company) }
  let(:user){ create(:user, company: company) }
  let(:ability) { Ability.new(user) }
  let(:account_admin) { user.add_role(:account_admin, company) }

  describe 'User' do

    describe 'super_admin abilities' do

      before(:each) do
        user.instance_variable_set(:@r_map, {})
        user.add_role(:super_admin)
      end

      it { expect(ability).to be_able_to(:read, user) }
      it { expect(ability).to be_able_to(:update, user) }
      it { expect(ability).to be_able_to(:manage, Company) }
      it { expect(ability).not_to be_able_to(:manage, User) }
      it { expect(ability).not_to be_able_to(:manage, Track) }

    end

    describe 'Normal user abilities' do

      it { expect(ability).to be_able_to(:read, user) }
      it { expect(ability).not_to be_able_to(:manage, Company) }
      it { expect(ability).not_to be_able_to(:manage, User) }

    end

    describe 'account_owner abilities' do

      let(:ability) { Ability.new(company.reload.owner) }

      it { expect(ability).to be_able_to(:read, user) }
      it { expect(ability).to be_able_to(:update, user) }
      it { expect(ability).to be_able_to(:manage, Track) }
      it { expect(ability).to be_able_to(:manage, User) }

    end

    describe 'account_admin abilities' do



      before(:each) do
        user.instance_variable_set(:@r_map, {})
        user.add_role(:account_admin)
      end


      it { expect(ability).to be_able_to(:read, user) }
      it { expect(ability).to be_able_to(:update, user) }
      it { expect(ability).to be_able_to(:manage, Track) }
      it { expect(ability).to be_able_to(:read, User) }
      it { expect(ability).to be_able_to(:create, User) }
      it { expect(ability).to be_able_to(:update, User) }
      it { expect(ability).not_to be_able_to(:update, company.owner) }
      it { expect(ability).not_to be_able_to(:update, account_admin) }

    end

  end

end
