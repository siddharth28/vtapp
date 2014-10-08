class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource, polymorphic: true

  #FIXME Test case of this scope.
  scope :with_name, ->(role_name) { where(name: role_name) }

  #FIXME Check how can we write test case for this.
  scopify
end
