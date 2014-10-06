class Company < ActiveRecord::Base

  has_many :users, inverse_of: :company, dependent: :destroy

  attr_accessor :owner_email, :owner_name

  after_create :make_owner

  ## FIXME_NISH Lets make an association of owner as discussed and also validate that there is always only one owner.

  scope :owner, -> { eager_load(:users).joins(:roles).where('roles.name' => 'account_owner') }

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true


  def self.load_users
    eager_load(:users).owners
  end
  def owner
    users.joins(:roles).where('roles.name' => 'account_owner').first
  end

  private
    def make_owner
      User.create!(name: owner_name, email: owner_email, company: self).add_role :account_owner
    end

  # FIXED
  ## FIXME_NISH why this callback is a after_commit?
  ## FIXME_NISH Please move this callback to user as discussed.
end
