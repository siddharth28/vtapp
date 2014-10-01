require 'rails_helper'

RSpec.describe Company, :type => :model do
  let(:company) { create(:company) }
  let(:account_owner_role) { create(:account_owner_role) }
  let(:user) { create(:user, company: company) }

  describe "attributes" do
    it { should respond_to(:name) }
    it { should respond_to(:enabled) }
  end

  describe "associations" do
    it { should have_many(:users).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
  describe "accept_nested_attributes_for" do
    it { should accept_nested_attributes_for(:users) }
  end

  describe "#owner" do
    before do
      account_owner_role
      company.users.first.add_role :account_owner
    end

    it { expect(company.owner).to eq(company.users.first) }
  end
end
