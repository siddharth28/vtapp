class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, user
    # FIXED
    # FIXME : Extract ability for each role in separate method
    super_admin_abilities(user)
    account_owner_abilities(user)
    account_admin_abilities(user)
    track_owner_abilities(user)
    track_runner_abilities(user)
  end

  private

    def super_admin_abilities(user)
      if user.super_admin?
        can :update, user
        can :manage, Company
      end
    end

    def account_owner_abilities(user)
      if user.account_owner?
        can :update, user
        can :manage, User, company: user.company
        can :manage, Track, company: user.company
        can :manage, Task
      end
    end

    def account_admin_abilities(user)
      if user.account_admin?
        can :update, user
        can [:read, :create, :autocomplete_user_name, :autocomplete_user_department], User, company: user.company
        can :update, User do |other_user|
          !(other_user.account_owner? || other_user.account_admin?)
        end
        can :manage, Track, company: user.company
        can :manage, Task
      end
    end

    def track_owner_abilities(user)
      can :manage, Track do |track|
        track.owner == user
      end
      can :manage, Task do |task|
        user.is_track_owner_of?(task.track)
      end
    end

    def track_runner_abilities(user)
      can :read, Track do |track|
        user.is_track_runner_of?(track)
      end
      can :manage, Usertask do |user_task|
        user_task.user_id == user.id
      end
      can :index, Task if user.is_track_runner_of?(:any)
    end
end
