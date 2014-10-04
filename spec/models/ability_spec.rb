require 'cancan/matchers'
require 'rails_helper'

describe Ability do
  let(:user){ create(:user) }
  let(:super_admin_role) { create(:role) }
  let(:company) { create(:company) }
  let(:ability) { Ability.new(user) }
  describe 'User' do
    describe 'super_admin abilities' do
      before do
        super_admin_role
        user.add_role :super_admin
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
