class User < ActiveRecord::Base

  ROLES = { super_admin: 'super_admin', account_owner: 'account_owner', account_admin: 'account_admin' }
  TRACK_ROLES = { track_runner: :track_runner }
  TASK_STATES = { in_progress: 'Started', submitted: 'Pending for review', completed: 'Completed'}

  rolify before_add: :ensure_only_one_account_owner, before_remove: :ensure_cannot_remove_account_owner_role, if: ActiveRecord::Base.connection.table_exists?(:roles)
  devise :database_authenticatable, :registerable, :async,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :mentees, class_name: User, foreign_key: :mentor_id, dependent: :restrict_with_error
  has_many :tracks, through: :roles, source: :resource, source_type: 'Track'
  has_many :usertasks, dependent: :destroy
  has_many :tasks, through: :usertasks

  belongs_to :company
  belongs_to :mentor, class_name: User

  #FIXED
  #FIXME -> Write rspec of this line.
  attr_readonly :email, :company_id

  validates :mentor, presence: true, if: :mentor_id?
  #FIXED
  #FIXME -> Write rspec of this validation.
  validates :company, presence: true, unless: :super_admin?
  validates :name, presence: true

  #email validation is provided by devise
  #FIXME_AB: no validation on email

  before_destroy :ensure_an_account_owners_and_super_admin_remains
  before_validation :set_random_password, on: :create
  #FIXME -> after_commit rspec remained
  after_commit :send_password_email, on: :create


  scope :with_company, ->(company) { where(company: company) }
  scope :group_by_department, -> { group(:department) }
  scope :with_company, ->(company_id) { where(company_id: company_id) }

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

  def track_ids=(track_list)
    track_list.map!(&:to_i)
    #FIXED
    #FIXME : This comparison is not correct, arrays should not compared like this
    if track_ids.sort != track_list.sort
      remove_track_objects = track_ids.reject { |track| track_list.include? track }.map { |track| Track.find_by(id: track) }
      add_track_objects = track_list.reject { |track| track_ids.include? track }.map { |track| Track.find_by(id: track) }
      add_track_objects.each { |track| add_role TRACK_ROLES[:track_runner], track }
      remove_track_objects.each { |track| remove_role TRACK_ROLES[:track_runner], track }
    end
  end

  def track_ids
    self.persisted? ? Track.with_role(TRACK_ROLES[:track_runner], self).ids : []
  end

  def mentor_name
    #CHANGED
    #TIP : we can use mentor.try(:name) and can eliminate if mentor
    mentor.try(:name)
  end

  def admin
    account_admin?
  end

  def admin=(value)
    value == '1' ? add_role(ROLES[:account_admin], company) : remove_role(ROLES[:account_admin], company)
  end

  def current_task_state?(task_id)
    !!find_users_task(task_id).try(:aasm_state)
  end

  def current_task_state(task_id)
    TASK_STATES[find_users_task(task_id).try(:aasm_state).try(:to_sym)]
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
    ## Sir actually we cannot perform these actions from the application. these are just model level validations.
    ## So these actions can be performed only from the console.
    #FIXME_AB: why are we raising exceptoins from callbacks. would returning false not help? Also, if raising exception is only solution, we should handle the exception.
    def ensure_only_one_account_owner(role)
      if role.name == ROLES[:account_owner] && company.owner.first
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

    def display_user_details
      "#{ name } : #{ email }"
    end

    def find_users_task(task_id)
      usertasks.find_by(task_id: task_id)
    end
end
