class User < ActiveRecord::Base

  ROLES = { super_admin: 'super_admin', account_owner: 'account_owner', account_admin: 'account_admin' }

  rolify before_add: :ensure_only_one_account_owner, before_remove: :ensure_cannot_remove_account_owner_role, after_add: :assign_usertasks

  devise :database_authenticatable, :registerable, :async, :recoverable, :rememberable, :trackable, :validatable

  has_many :mentees, class_name: 'User', foreign_key: :mentor_id, dependent: :restrict_with_error
  has_many :tracks, -> { uniq }, through: :roles, source: :resource, source_type: 'Track'
  has_many :usertasks, dependent: :destroy
  has_many :tasks, through: :usertasks
  has_many :tracks_with_role_runner, -> { where(roles: { name: Track::ROLES[:track_runner] }) }, through: :roles, source: :resource, source_type: 'Track'

  belongs_to :company
  belongs_to :mentor, class_name: 'User'

  attr_readonly :email, :company_id

  validates :mentor, presence: true, if: :mentor_id?
  validates :company, presence: true, unless: :super_admin?
  validates :name, presence: true

  ## FIXED
  ## FIXME_NISH Please verify if we require to override these validations already present in devise.

  validates :email, :name, :department, length: { maximum: 255 }

  before_destroy :ensure_an_account_owners_and_super_admin_remains
  before_validation :set_random_password, on: :create
  #FIXME -> after_commit rspec remained
  after_commit :send_password_email, on: :create

  scope :with_company, ->(company) { where(company: company) }
  scope :group_by_department, -> { group(:department) }

  delegate :name, to: :mentor, prefix: :mentor, allow_nil: true

  ROLES.each do |key, method|
    define_method "#{ method }?" do
      roles.any? { |role| role.name == "#{ method }" }
    end
  end

  def active_for_authentication?
    if super_admin?
      super
    else
      super && enabled && company.enabled
    end
  end

  def tracks_with_role_runner_ids=(track_list)
    track_list.map!(&:to_i)
    remove_track_object_ids = tracks_with_role_runner_ids - track_list
    add_track_object_ids = track_list - tracks_with_role_runner_ids
    remove_role_track_runner(remove_track_object_ids) unless remove_track_object_ids.blank?
    add_role_track_runner(add_track_object_ids) unless add_track_object_ids.blank?
  end

  ## FIXED
  ## FIXME_NISH use delegate.

  def add_role_account_admin
    add_role(ROLES[:account_admin], company)
  end

  def remove_role_account_admin
    remove_role(ROLES[:account_admin], company)
  end

  private
    def set_random_password
      self.password_confirmation = self.password = Devise.friendly_token.first(8)
    end

    def send_password_email
      ## FIXED
      ## FIXME_NISH We don't need the following two lines.
      UserMailer.delay.welcome_email(email, password)
    end

    #rolify callback
    #FIXED because this functionality is only for console view it's not in app so it won't occur in view
    #FIXME_AB: I could not get you by console view, Please elaborate
    ## Sir actually we cannot perform these actions from the application. these are just model level validations.
    ## So these actions can be performed only from the console.
    #FIXME_AB: why are we raising exceptoins from callbacks. would returning false not help? Also, if raising exception is only solution, we should handle the exception.
    def ensure_an_account_owners_and_super_admin_remains
      if super_admin?
        errors.add(:base, 'Can\'t delete super admin')
      elsif account_owner?
        errors.add(:base, 'Can\'t delete Account Owner')
      end
    end

    def ensure_only_one_account_owner(role)
      if role.name == ROLES[:account_owner] && company.owner
        errors.add(:base, 'There can be only one account owner')
      end
    end

    #rolify callback
    def ensure_cannot_remove_account_owner_role(role)
      if role.name == ROLES[:account_owner]
        errors.add(:base, 'Cannot remove account_owner role')
      end
    end

    def display_details
      ## FIXED
      ## FIXME_NISH Please remove user in the method name.
      "#{ name } : #{ email }"
    end


    def add_role_track_runner(add_track_object_ids)
      Track.where(id: add_track_object_ids).each { |track| add_role(Track::ROLES[:track_runner], track) }
    end

    def remove_role_track_runner(remove_track_object_ids)
      Track.where(id: remove_track_object_ids).each { |track| remove_role(Track::ROLES[:track_runner], track) }
    end

    def assign_usertasks(role)
      if role.name == Track::ROLES[:track_runner]
        already_assigned_tasks = usertasks.pluck(:task_id)
        tasks = role.resource.tasks.visible_tasks.where.not(id: already_assigned_tasks).includes(:actable)
        tasks.each { |task| usertasks.build(task: task) }
      end
    end

end
