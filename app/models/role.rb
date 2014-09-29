class Role < ActiveRecord::Base
  ## FIXME_NISH Verify if we need to specify join_table.
  ## FIXME_NISH Use new syntax of hash.
  ## FIXME_NISH Please specify dependent condition with associations.
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  ## FIXME_NISH change scope name ti with_name
  ## FIXME_NISH don't use 'roles.name'
  scope :find_role, ->(role_name) { where(:'roles.name' => role_name) }

  scopify
end
