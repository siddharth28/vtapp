FactoryGirl.define do
  factory :company do
    name "Test Company"
    enabled true
    # association :users, factory: :user, strategy: :build
  end
end
