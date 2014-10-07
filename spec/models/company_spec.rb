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
    before(:each) do
      Company.any_instance.stub(:make_owner)
    end

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

end
