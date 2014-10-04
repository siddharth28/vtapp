class Ability
  include CanCan::Ability
  def initialize(user)
    ## FIXME_NISH Refactor the code in ability.
    user ||= User.new # guest user (not logged in)
    can :manage, user
    if user.has_role? :super_admin
      ## FIXME_NISH if user is super admin, I think we should allow him to can :manage, :all
      can :manage, Company
    end
  end
end
