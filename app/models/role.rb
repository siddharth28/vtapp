class Role < ActiveRecord::Base
  ## FIXED
  ## FIXME_NISH Verify if we need to specify join_table.
  ## FIXED
  ## FIXME_NISH Use new syntax of hash.
  ## FIXED
  ## FIXME_NISH Please specify dependent condition with associations.
  has_and_belongs_to_many :users, join_table: :users_roles, dependent: :nullify
  belongs_to :resource, polymorphic: true
  ## FIXED
  ## FIXME_NISH change scope name ti with_name
  ## FIXED
  ## FIXME_NISH don't use 'roles.name'
  scope :with_name, ->(role_name) { where(name: role_name) }

  scopify
end
