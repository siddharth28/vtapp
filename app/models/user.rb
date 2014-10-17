class User < ActiveRecord::Base
  ROLES = { super_admin: :super_admin, account_owner: :account_owner, account_admin: :account_admin }
  rolify before_add: :ensure_only_one_account_owner, before_remove: :ensure_cannot_remove_account_owner_role
  devise :database_authenticatable, :registerable, :async,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :mentees, class_name: User, foreign_key: :mentor_id, dependent: :restrict_with_error
  belongs_to :company
  belongs_to :mentor, class_name: User
  # has_many :tracks, ->{ joins(:roles).tracks }
  has_many :tracks, through: :roles, source: :resource, source_type: 'Track'

  #FIXME -> Write rspec of this line.
  attr_readonly :email, :company_id
  attr_accessor :admin

  validates :mentor, presence: true, if: :mentor_id?
  #FIXME -> Write rspec of this validation.
  validates :company, presence: true, if: -> { !super_admin? }
  validates :name, presence: true


  #email validation is provided by devise
  #FIXME_AB: no validation on email

  before_destroy :ensure_an_account_owners_and_super_admin_remains
  before_validation :set_random_password, on: :create
  #FIXME -> after_commit rspec remained
  after_commit :send_password_email, on: :create
  after_save :check_admin
  after_initialize :set_admin

  def active_for_authentication?
    if super_admin?
      super
    else
      super && enabled && company.enabled
    end
  end

  ROLES.each do |key, method|
    define_method "#{ method }?" do
      roles.any? { |role| role.name == "#{ method }" }
    end
  end

  private
    def set_random_password
      self.password_confirmation = self.password = Devise.friendly_token.first(8)
    end

    def send_password_email
      password = self.password
      email = self.email
      UserMailer.delay.welcome_email(email, password)
    end

    def ensure_an_account_owners_and_super_admin_remains
      if super_admin?
        raise 'Can\'t delete Super Admin'
      elsif account_owner?
        raise 'Can\'t delete Account Owner'
      end
    end
    #rolify callback
    #FIXED because this functionality is only for console view it's not in app so it won't occur in view
    #FIXME_AB: I could not get you by console view, Please elaborate
    ## Sir ctually we cannot perform these actions from the application. these are just model level validations.
    ## So these actions can be performed only from the console. 
    #FIXME_AB: why are we raising exceptoins from callbacks. would returning false not help? Also, if raising exception is only solution, we should handle the exception.
    def ensure_only_one_account_owner(role)
      if role.name == ROLES[:account_owner] && !Company.with_role(ROLES[:account_owner], company)
        #FIXED
        #FIXME_AB: WE can avoid this nested if statement.
        raise 'There can be only one account owner'
      end
    end
    #rolify callback
    def ensure_cannot_remove_account_owner_role(role)
      if role.name == ROLES[:account_owner]
        raise 'Cannot remove account_owner role'
      end
    end

    #FIXME self is not required. Also, write rspec of this method.
    def display_track_owner_details
      "#{ name } :#{ email }"
    end

    def check_admin
      admin ? remove_role(ROLES[:account_admin], company) : add_role(ROLES[:account_admin], company)
    end
    def set_admin
      account_admin? ? self.admin = true : self.admin = false
    end
    def display_user_details
      "#{ self.name } : #{ self.email }"
    end
end
