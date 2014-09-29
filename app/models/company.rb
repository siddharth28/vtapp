class Company < ActiveRecord::Base
  ## FIXME_NISH Please specify dependent condition with associations.
  has_many :users

  ## FIXME_NISH Divide the validation in two parts presence and uniqueness. And pass allow_blank: true option
  ## with uniqueness
  validates :name, presence: true, uniqueness: true
  accepts_nested_attributes_for :users

  ## FIXME_NISH make owner a method and delegate email to owner.

  def owner_email
    users.owner.first.email
  end

end
