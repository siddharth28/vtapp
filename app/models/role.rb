class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource, polymorphic: true

  #FIXME Change rspec as discussed
  scope :with_name, ->(role_name) { where(name: role_name) }

  scopify
end
