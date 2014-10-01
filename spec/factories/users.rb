FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'test@example.com'
    password 'please123'
    enabled true
    company_id 1
  end

  factory :company do
    name 'Test Company'
    enabled true
  end
end
