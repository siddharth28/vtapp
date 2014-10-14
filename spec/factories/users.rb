FactoryGirl.define do
  factory :user do
    name 'Test User'
    email 'test@example.com'
    password 'please123'
    enabled true
  end

  factory :track_owner_user, class: 'User' do
    name 'Test Owner'
    email 'track_owner_email@owner.com'
    password 'please123'
    enabled true
  end
end
