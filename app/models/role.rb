class Role < ActiveRecord::Base

  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  ## FIXME_NISH Don't add role in scope name.
  scope :track_with_role, ->(role_name) { where(name: role_name, resource_type: 'Track') }

  scopify
end
