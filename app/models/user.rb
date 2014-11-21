class User < ActiveRecord::Base

  ROLES = { super_admin: 'super_admin', account_owner: 'account_owner', account_admin: 'account_admin' }

  rolify before_add: :ensure_only_one_account_owner, before_remove: :ensure_cannot_remove_account_owner_role, after_add: :assign_usertasks

  devise :database_authenticatable, :registerable, :async, :recoverable, :rememberable, :trackable, :validatable

  has_many :mentees, class_name: User, foreign_key: :mentor_id, dependent: :restrict_with_error
  has_many :tracks, -> { uniq }, through: :roles, source: :resource, source_type: 'Track'
  has_many :usertasks, dependent: :destroy
  has_many :tasks, through: :usertasks
  has_many :tracks_with_role_runner, -> { where(roles: { name: Track::ROLES[:track_runner] }) }, through: :roles, source: :resource, source_type: 'Track'

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
  validates :password, presence: true, on: :create
  validates :password_confirmation, presence: true, allow_blank: true
  validates :email, :name, :department, length: { maximum: 255 }

  before_destroy :ensure_an_account_owners_and_super_admin_remains
  before_validation :set_random_password, on: :create
  #FIXME -> after_commit rspec remained
  after_commit :send_password_email, on: :create

  scope :with_company, ->(company) { where(company: company) }
  scope :group_by_department, -> { group(:department) }

  ROLES.each do |key, method|
    define_method "#{ method }?" do
      roles.any? { |role| role.name == "#{ method }" }
    end
  end

  # Not Fixed
  #FIXED
  #FIXME : method name not correct

  def active_for_authentication?
    if super_admin?
      super
    else
      super && enabled && company.enabled
    end
  end

  def tracks_with_role_runner_ids=(track_list)
    track_list.map!(&:to_i)
    # comparison not required now.
    # FIXME : Where is comparison moved ?
    # FIXED
    # NOT FIXED
    # FIXED
    # FIXME : This comparison is not correct, arrays should not compared like this
    remove_track_object_ids = tracks_with_role_runner_ids - track_list
    add_track_object_ids = track_list - tracks_with_role_runner_ids
    # TIP : Can use unless here.
    remove_role_track_runner(remove_track_object_ids) unless remove_track_object_ids.blank?
    add_role_track_runner(add_track_object_ids) unless add_track_object_ids.blank?
  end

  # FIXME : use user scope here and change accordingly
  def mentor_name
    #CHANGED
    #TIP : we can use mentor.try(:name) and can eliminate if mentor
    mentor.try(:name)
  end

  #FIXME : create reader for this

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
      password = self.password
      email = self.email
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
        raise 'Can\'t delete Super Admin'
      elsif account_owner?
        raise 'Can\'t delete Account Owner'
      end
    end

    def ensure_only_one_account_owner(role)
      if role.name == ROLES[:account_owner] && company.owner
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


    def add_role_track_runner(add_track_object_ids)
      Track.where(id: add_track_object_ids).each { |track| add_role(Track::ROLES[:track_runner], track) }
    end

    def remove_role_track_runner(remove_track_object_ids)
      Track.where(id: remove_track_object_ids).each { |track| remove_role(Track::ROLES[:track_runner], track) }
    end

    def assign_usertasks(role)
      if role.name == Track::ROLES[:track_runner]
        tasks = role.resource.tasks.visible_tasks.includes(:actable)
        tasks.each { |task| usertasks.build(task: task) unless usertasks_exists?(task.id) }
      end 
    end

    def usertasks_exists?(task_id)
      usertasks.any? { |usertask| usertask.task_id.eql?(task_id) }
    end
end
