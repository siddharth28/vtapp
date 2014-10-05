require 'rails_helper'

describe Company do
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

end
