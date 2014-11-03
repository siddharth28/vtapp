class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, user
    can :update, user if user.super_admin? || user.account_owner? || user.account_admin?
    if user.super_admin?
      can :manage, Company
    elsif user.account_owner?
      can :manage, User, company: user.company
      can :manage, Track, company: user.company
    elsif user.account_admin?
      can [:read, :create, :autocomplete_user_name, :autocomplete_user_department], User, company: user.company
      can :update, User do |other_user|
        !(other_user.account_owner?)
      end
      can :manage, Track, company: user.company
    end
  end
end
