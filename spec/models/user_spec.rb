require 'rails_helper'

RSpec.describe User, :type => :model do
  before(:each) { @user = User.new(name: "Test User", password: "please123", email: 'user@example.com') }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:company_id) }

  it "#email returns a string" do
    expect(@user.email).to match 'user@example.com'
  end
end
