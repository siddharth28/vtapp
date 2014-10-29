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
      can :manage, Task
    elsif user.account_admin?
      can :read, User
      can :create, User
      can :update, User do |other_user|
        !(other_user.account_owner? || other_user.account_admin?)
      end
      can :manage, Track, company: user.company
    elsif
      can :manage, Track, company: user.company
      can :read, Task
      can :start_task, User
      can :task_description, User
      can :submit_task, User
    end
  end
end
