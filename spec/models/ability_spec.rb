require 'cancan/matchers'
require 'rails_helper'

describe Ability do
  let(:company) { create(:company) }
  let(:user){ create(:user, company: company) }
  let(:super_admin_role) { create(:super_admin_role) }
  let(:account_owner_role) { create(:account_owner_role) }

  let(:ability) { Ability.new(user) }
  describe 'User' do
    describe 'super_admin abilities' do
      before(:each) do
        super_admin_role
        user.instance_variable_set(:@r_map, {})
        user.add_role(:super_admin)
      end
      it{ expect(ability).to be_able_to(:manage, user) }
      it{ expect(ability).to be_able_to(:manage, Company) }
      it{ expect(ability).not_to be_able_to(:manage, User) }
      it{ expect(ability).not_to be_able_to(:manage, Track) }
    end
    describe 'Normal user abilities' do
      it{ expect(ability).to be_able_to(:manage, user) }
      it{ expect(ability).not_to be_able_to(:manage, Company) }
      it{ expect(ability).not_to be_able_to(:manage, User) }
    end
    describe 'account_owner abilities' do
      let(:ability) { Ability.new(company.owner) }
      it{ expect(ability).to be_able_to(:manage, Track) }
      it{ expect(ability).not_to be_able_to(:manage, Company) }
    end
  end
end
