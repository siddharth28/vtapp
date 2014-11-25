class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    normal_user_abilities(user)
    super_admin_abilities(user)
    account_owner_abilities(user)
    account_admin_abilities(user)
    track_owner_abilities(user)
    track_reviewer_abilities(user)
    track_runner_abilities(user)
  end

  private

    def normal_user_abilities(user)
      can :read, user
    end

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

    def track_reviewer_abilities(user)
      can :read, Track do |track|
        user.is_track_reviewer_of?(track)
      end
      can :manage, Usertask do |user_task|
        user_task.reviewer_id == user.id
      end
      can :assign_to_me, Usertask
    end

    def track_runner_abilities(user)
      can :read, Track do |track|
        user.is_track_runner_of?(track)
      end
      can :start, Usertask do |user_task|
        user_task.user_id == user.id
      end
      can [:read, :submit_url, :submit_comment, :resubmit, :restart], Usertask do |user_task|
        user_task.user_id == user.id && !user_task.not_started?
      end
    end

end
