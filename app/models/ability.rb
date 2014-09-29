class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    ## FIXME_NISH Please verify abilities.
    user ||= User.new # guest user (not logged in)
    can :sign_in if user.has_role? :super_admin || (user.company.enabled && user.enabled)
    can :manage, user
    if user.has_role? :super_admin
      ## FIXME_NISH if user is super admin, I think we should allow him to can :manage, :all
      can :manage, Company
      can :manage, user if user.has_role? :account_owner
    elsif user.has_role? :account_owner
      can :manage, user.company
      can :manage, User do |new_user|
        ## FIXME_NISH why we are doing this in ability.rb?
        new_user.add_role 'admin'
        new_user.company == user.company
      end
    elsif user.has_role? :admin
      can :manage, user.company.users
    end

    ## FIXME_NISH Remove the following comments.


    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
