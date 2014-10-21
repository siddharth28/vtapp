FactoryGirl.define do
  factory :track do
    name 'Test Track'
    enabled true
    references 'references'
    instructions 'instruction'
    description 'descriptions'
    owner_id 11111
    owner_name 'Owner'
    reviewer_id 99999
    reviewer_name 'Reviewer'
  end

  factory :track_without_owner, class: 'Track' do
    name 'Test Track2'
    references 'references'
    instructions 'instruction'
    description 'descriptions'
    enabled true
  end
end
