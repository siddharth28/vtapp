class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new
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
      ## FIXME_NISH: Please change the name of the method.
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
        can [:read, :review, :submit_comment, :review_task, :assign_to_me], Usertask
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
        can [:read, :submit_comment, :assign_to_me], Usertask
      end
    end

    def track_owner_abilities(user)
      can :manage, Track, owner_id: user.id
      can :manage, Task do |task|
        user.is_track_owner_of?(task.track)
      end
      can [:read, :submit_comment, :assign_to_me], Usertask do |user_task|
        user.is_track_owner_of?(user_task.task.track)
      end
    end

    def track_reviewer_abilities(user)
      can [:read, :runners, :reviewers], Track do |track|
        user.is_track_reviewer_of?(track)
      end
      can [:read, :review, :submit_comment, :review_exercise], Usertask, reviewer_id: user.id

      can :assign_to_me, Usertask do |user_task|
        user_task.task.track.reviewers.include?(user)
      end
    end

    def track_runner_abilities(user)
      can :read, Track do |track|
        user.is_track_runner_of?(track)
      end
      can :start, Usertask do |user_task|
        user_task.user_id == user.id && user_task.not_started?
      end
      can [:read, :submit_task], Usertask do |user_task|
        user_task.user_id == user.id && !user_task.not_started? && !user_task.task.need_review?
      end
      can [:read, :submit_url, :resubmit], Usertask do |user_task|
        user_task.user_id == user.id && !user_task.not_started? && !user_task.restart? && user_task.task.need_review?
      end
      can :restart, Usertask do |user_task|
        user_task.user_id == user.id && user_task.restart?
      end
      can :submit_comment, Usertask do |user_task|
        user_task.user_id == user.id
      end
    end

end
