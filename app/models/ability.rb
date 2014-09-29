class Ability
  include CanCan::Ability

  def initialize(user)
    ## FIXME_NISH Please verify abilities.
    user ||= User.new # guest user (not logged in)
    can :sign_in if user.has_role? :super_admin || (user.company.enabled && user.enabled)
    can :manage, user
    if user.has_role? :super_admin
      ## FIXME_NISH if user is super admin, I think we should allow him to can :manage, :all
      can :manage, Company
      can :manage, user if user.has_role? :account_owner
    end
    ## FIXED
    ## FIXME_NISH Remove the following comments.
  end
end
