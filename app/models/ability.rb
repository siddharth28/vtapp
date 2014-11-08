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
      can [:read, :create, :autocomplete_user_name, :autocomplete_user_department], User, company: user.company
      can :update, User do |other_user|
        !(other_user.account_owner? || other_user.account_admin?)
      end
      can :manage, Track, company: user.company
      can :manage, Task
    elsif
      can :manage, Track do |track|
        track.owner == user
      end
      can :manage, Task do |task|
        user.is_track_owner_of(task.track)
      end
      can :read, Track do |track|
        user.is_track_runner_of?(track)
      end
      can :index, Task
      can :manage, Usertask do |user_task|
        user_task.user_id == user.id
      end
    end
  end
end
