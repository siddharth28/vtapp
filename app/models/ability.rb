class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :manage, user
    if user.has_role? :super_admin
      can :manage, Company
    elsif user.has_role? :account_owner
      can :manage, User, company: user.company
      can :manage, Track
    end
    if(user.account_owner? || user.account_admin?)
      can :manage, User, company: user.company
    end
  end
end
