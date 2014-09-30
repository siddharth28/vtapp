class Company < ActiveRecord::Base
  ## FIXME_NISH Please specify dependent condition with associations.
  has_many :users, dependent: :destroy
  ## FIXED
  ## FIXME_NISH Divide the validation in two parts presence and uniqueness. And pass allow_blank: true option
  ## with uniqueness
  validates :name, presence: true
  validates :name, uniqueness: { allow_blank: true }
  accepts_nested_attributes_for :users
  after_commit :make_owner, on: :create
  ## FIXED
  ## FIXME_NISH make owner a method and delegate email to owner.
  def owner
    users.owner.first
  end
  private
    def make_owner
      users.first.add_role(:account_owner)
    end
end
