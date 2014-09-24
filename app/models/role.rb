class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  scope :find_role, ->(role_name) { where(:'roles.name' => role_name) }

  scopify
end
