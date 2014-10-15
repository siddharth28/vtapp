FactoryGirl.define do
  factory :track do
    name 'Test Track'
    enabled true
    references 'references'
    instructions 'instruction'
    description 'descriptions'
    owner_name 'Test Owner'
    owner_email 'track_owner_email@owner.com'
  end

  factory :track_without_owner, class: 'Track' do
    name 'Test Track2'
    references 'references'
    instructions 'instruction'
    description 'descriptions'
    enabled true
  end
end
