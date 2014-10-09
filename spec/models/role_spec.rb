require 'rails_helper'

describe Role do

  describe 'associations' do
    describe 'has_many association' do
      it { should have_and_belong_to_many(:users) }
    end

    describe 'belongs_to' do
      it { should belong_to(:resource) }
    end
  end

  describe 'scope' do
    describe '#with_name' do
      let(:super_admin_role) { create(:super_admin_role) }
      it { expect(Role.with_name('super_admin')).to eq([super_admin_role]) }
      it { expect(Role.with_name('account_owner')).to be_blank }
    end
  end
end
