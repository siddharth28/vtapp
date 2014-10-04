FactoryGirl.define do
  factory :role do
    name 'super_admin'
  end
  factory :account_owner_role, class: 'Role' do
    name "account_owner"
  end
end
