FactoryGirl.define do
  factory :company do
    name 'Test Company'
    enabled true
    owner_name 'Test Owner'
    owner_email 'owner_email@owner.com'
  end
end
