class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles, dependent: :nullify

  belongs_to :resource, polymorphic: true

  scopify
end
