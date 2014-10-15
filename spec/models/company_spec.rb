require 'rails_helper'

describe Company do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }

  describe 'associations' do
    it { should have_many(:users).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'callbacks' do
    describe 'after_create' do
      describe 'build_owner' do
        it { expect(company.owner).not_to eql(nil) }
      end
    end
  end

  describe 'instance methods' do
    describe '#owner' do
      it { expect(company.owner.all? { |user| user.has_role?(:account_owner) }).to eql(true)}
      it { expect(company.owner.first.name).to eql('Test Owner')}
    end

    describe '#build_owner' do
      let(:company) { build(:company) }
      before { company.save }
      it { expect(company.owner.first.name).to eql('Test Owner') }
    end

    describe 'attr_accessor' do
      let(:company) { build(:company) }
      describe '#owner_email' do
        it { expect(company.owner_email).to eql('owner_email@owner.com') }
      end

      describe '#owner_email=' do
        before { company.owner_email= 'Changed Email' }
        it { expect(company.owner_email).to eql('Changed Email') }
      end

      describe '#owner_name' do
        it { expect(company.owner_name).to eql('Test Owner') }
      end

      describe '#owner_name=' do
        before { company.owner_name = 'Changed Name' }
        it { expect(company.owner_name).to eq('Changed Name')  }
      end
    end
  end

  #FIXME -> Change rspecs of these scopes as discussed.
  describe 'scopes' do
    describe 'load_with_owners' do
      let(:user) { create(:user, company: company) }

      it { expect(Company.load_with_owners.include?(company)).to eq(true) }

      context 'user owner' do
        it { expect(Company.eager_load(:users).find(company).users.all? { |user| user.has_role?(:account_owner) }).to eq(true) }
      end

      context 'user not owner' do
        it { expect(Company.eager_load(:users).find(company).users.include?(user)).to eq(false) }
      end

      describe 'eager_load' do
        before { allow(Company).to receive(:eager_load).and_return(Company) }

        it { expect(Company).to receive(:eager_load) }

        after { Company.load_with_owners }
      end
    end

    describe 'enabled' do
      let(:disabled_company) { create(:company, enabled: false) }

      it { expect(Company.enabled.include?(company)).to eq(true) }
      it { expect(Company.enabled.include?(disabled_company)).to eq(false) }
    end
  end
end
