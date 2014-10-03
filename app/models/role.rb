class Role < ActiveRecord::Base
  ## FIXED
  ## FIXME_NISH Verify if we need to specify join_table.
  has_and_belongs_to_many :users, join_table: :users_roles, dependent: :nullify
  ## FIXME_NISH do we required this resource association?
  belongs_to :resource, polymorphic: true

  scope :with_name, ->(role_name) { where(name: role_name) }

  scopify
end
