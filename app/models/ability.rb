class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :manage, user
    if user.has_role? :super_admin
      can :manage, Company
    end
  end
end
