require 'rails_helper'

describe Company do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }

  describe 'attributes' do
    it { should respond_to(:name) }
    it { should respond_to(:enabled) }
    it { should respond_to(:owner_name) }
    it { should respond_to(:owner_email) }
  end

  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'callbacks' do
    describe 'after_create' do
      describe 'make_owner' do
        it { expect(company.owner).not_to eql(nil) }
      end
    end
  end

  describe 'instance methods' do
    describe '#owner' do
      it { expect(company.owner.has_role?(:account_owner)).to eql(true)}
    end
  end

  describe 'scopes' do
    describe 'load_with_owners' do
      before do
        allow(Company).to receive(:eager_load).and_return(:users)
      end
      it { expect(Company.load_with_owners).to_return}
    end
  end

end
