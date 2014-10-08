require 'cancan/matchers'
require 'rails_helper'

describe Ability do
  let(:company) { create(:company) }
  let(:user){ create(:user, company: company) }
  let(:super_admin_role) { create(:super_admin_role) }
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
    end
    describe 'Normal user abilities' do
      it{ expect(ability).to be_able_to(:manage, user) }
      it{ expect(ability).not_to be_able_to(:manage, Company) }
      it{ expect(ability).not_to be_able_to(:manage, User) }
    end
  end
end
