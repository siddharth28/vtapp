class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :sign_in if user.has_role? :super_admin || (user.company.enabled && user.enabled)
    can :manage, user
    if user.has_role? :super_admin
      can :manage, Company
      can :manage, user if user.has_role? :account_owner
    end
  end
end
