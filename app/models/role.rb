class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles
  has_one :link
  belongs_to :resource, polymorphic: true
  #FIXED
  #FIXME Change rspec as discussed
  scope :with_name, ->(role_name) { where(name: role_name) }

  scopify
end
