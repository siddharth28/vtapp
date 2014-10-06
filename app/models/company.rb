class Company < ActiveRecord::Base

  has_many :users, inverse_of: :company, dependent: :destroy

  ## FIXME_NISH Lets make an association of owner as discussed and also validate that there is always only one owner.

  accepts_nested_attributes_for :users

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true

  scope :load_users, -> { eager_load(:users).joins(users: :roles).merge(Role.with_name('account_owner')) }

  def owner
    users.first
  end
end
