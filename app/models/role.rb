class Role < ActiveRecord::Base
  ## FIXED
  ## FIXME_NISH Verify if we need to specify join_table.
  has_and_belongs_to_many :users, join_table: :users_roles, dependent: :nullify

  # FIXED Yes! this association is required as it is used to form a relation b/w User and Role
  ## FIXME_NISH do we required this resource association?
  belongs_to :resource, polymorphic: true

  scope :with_name, ->(role_name) { where(name: role_name) }

  scopify
end
