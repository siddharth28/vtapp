require 'rails_helper'

describe User do
  let(:company) { create(:company) }
  let(:mentor) { build(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { build(:user, mentor_id: mentor.id, company: company) }
  #FIXED
  #FIXME -> Check constant value.
  describe 'constants' do
    describe 'adminstrator roles' do
      it { User.should have_constant(:ROLES) }
      it { expect(User::ROLES[:super_admin]).to eql('super_admin') }
      it { expect(User::ROLES[:account_owner]).to eql('account_owner') }
      it { expect(User::ROLES[:account_admin]).to eql('account_admin') }
      it { expect(User::ROLES[:track_owner]).to eql('track_owner') }
      it { expect(User::ROLES[:track_runner]).to eql('track_runner') }
      it { expect(User::ROLES[:track_reviewer]).to eql('track_reviewer') }
    end
  end

  describe 'associations' do
    #FIXED
    #FIXME -> Check class_name also
    describe 'has_many association' do
      it { should have_many(:mentees).class_name(User).with_foreign_key(:mentor_id).dependent(:restrict_with_error) }
      it { should have_many(:tracks).through(:roles).source(:resource) }
      it { should have_many(:tasks).through(:usertasks) }
      it { should have_many(:usertasks).dependent(:destroy) }
    end

    describe 'belongs_to' do
      it { should belong_to(:company) }
      #FIXED
      #FIXME To check class_name there is a should_a matcher.
      it { should belong_to(:mentor).class_name(User) }
    end
  end

  describe 'validation' do
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:name) }

    context 'user is a super_admin' do
      let(:user) { build(:user) }

      before { user.add_role(:super_admin) }

      it { expect(user.valid?).to eql(true) }
    end
    #FIXED
    #FIXME -> Why this context ?
    #FIXED
    #FIXME Change rspec as discussed.

    describe 'mentor validation' do
      context 'mentor not present' do
        it { should_not validate_presence_of(:mentor) }
      end

      context 'valid mentor present' do
        let(:user) { build(:user, mentor_id: mentor.id, company: company) }

        it { expect(user.valid?).to eql(true) }
      end
      #FIXED
      #FIXME -> Also check error message.
      context 'invalid mentor present' do
        let(:user) { build(:user, mentor_id: 3920220, company: company) }

        before { user.valid? }

        it { expect(user.errors[:mentor].include?("can't be blank")).to eql(true) }
      end
    end
  end

  describe 'attr_readonly' do
    let(:user) { create(:user, company: company) }
    it { expect{ user.update_attribute(:email, 'new_email@email.com')}.to raise_error('email is marked as readonly') }
    it { expect{ user.update_attribute(:company_id, 9239)}.to raise_error('company_id is marked as readonly') }
  end

  describe 'callbacks' do
    let(:company) { create(:company) }
    let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }
    #FIXED
    #FIXME Change as discussed.
    describe 'before validation#set_random_password' do
      it do
        expect { user.valid? }.to change{ user.password.nil? }.from(true).to(false)
        expect(user.password).to eq(user.password_confirmation)
      end
    end

    describe 'before destroy#ensure_an_account_owners_and_super_admin_remains' do
      context 'when super_admin' do
        before { user.add_role(:super_admin) }

        it { expect { user.destroy }.to raise_error("Can't delete Super Admin") }
      end

      context 'when account_owner' do
        it { expect { company.reload.owner.destroy }.to raise_error("Can't delete Account Owner") }
      end

      context 'neither super_admin nor account_owner' do
        before { user.add_role(:track_owner) }

        it { expect { user.destroy }.not_to raise_error }
      end
    end
  end

  describe 'instance methods' do
    let(:user) { build(:user, name: nil, email: nil, password: nil) }
    let(:company) { build(:company, name: 'Vinsol', enabled: true ) }

    describe '#super_admin?' do
      context 'is a super_admin' do
        before { user.add_role(:super_admin) }

        it { expect(user.super_admin?).to eql(true) }
      end

      context 'not a super_admin' do
        it { expect(user.super_admin?).to eql(false) }
      end
    end

    describe '#account_owner?' do
      context 'is an account_owner' do
        let(:company) { create(:company) }
        let(:user) { build(:user, name: nil, email: nil, password: nil, company: company) }

        it { expect(company.reload.owner.account_owner?).to eql(true) }
      end

      context 'not an account_owner' do
        it { expect(user.account_owner?).to eql(false) }
      end
    end


    describe '#account_admin?' do
      context 'is an account_admin' do
        before { user.add_role(:account_admin) }

        it { expect(user.account_admin?).to eql(true) }
      end

      context 'not an account_admin' do
        it { expect(user.account_admin?).to eql(false) }
      end
    end

    describe '#track_runner?' do
      context 'is a track_runner' do
        before { user.add_role(:track_runner) }

        it { expect(user.track_runner?).to eql(true) }
      end

      context 'not a track_runner' do
        it { expect(user.track_runner?).to eql(false) }
      end
    end

    describe '#track_owner?' do
      context 'is an track_owner' do
        before { user.add_role(:track_owner) }

        it { expect(user.track_owner?).to eql(true) }
      end

      context 'not an track_owner' do
        it { expect(user.track_owner?).to eql(false) }
      end
    end


    describe '#track_reviewer?' do
      context 'is an track_reviewer' do
        before { user.add_role(:track_reviewer) }

        it { expect(user.track_reviewer?).to eql(true) }
      end

      context 'not an track_reviewer' do
        it { expect(user.track_reviewer?).to eql(false) }
      end
    end

    describe '#active_for_authentication?' do
      context 'when super_admin' do
        before { user.add_role(:super_admin) }

        it { expect(user.active_for_authentication?).to eql(true) }
      end

      context 'not super_admin' do
        let(:user) { company.users.build({ name: 'Vinsol', enabled: true } ) }

        def status(user, state1, state2)
          user.enabled = state1
          user.company.enabled = state2
        end

        context 'company_enabled' do
          context 'user_disabled' do
            before { status(user, false, true) }

            it { expect(user.active_for_authentication?).to eql(false) }
          end

          context 'user_enabled' do
            before { status(user, true, true) }

            it { expect(user.active_for_authentication?).to eql(true) }
          end
        end

        context 'company_disabled' do
          context 'user_enabled' do
            before { status(user, true, false) }

            it { expect(user.active_for_authentication?).to eql(false) }
          end

          context 'user_disabled' do
            before { status(user, false, false) }

            it { expect(user.active_for_authentication?).to eql(false) }
          end
        end
      end
    end

    describe '#track_ids=' do
      let(:company) { create(:company) }
      let(:track) { create(:track, company: company) }
      let(:user) { create(:user, company: company) }

      context 'assign tracks' do
        let(:track_list) { [track.id] }

        before { user.track_ids = track_list }

        it { expect(user.tracks.include?(track)).to eql(true) }
      end

      context 'remove tracks' do
        let(:track_list) { [] }
        before do
          user.add_role(:track_runner, track)
          user.track_ids = track_list
        end
        it { expect(user.tracks.include?(track)).to eql(false) }
      end
    end

    describe '#track_ids' do
      it { expect(user.track_ids).to eql(user.tracks.ids) }
    end

    describe '#is_admin' do
      it { expect(user.is_admin).to eql(user.account_admin?) }
    end

    describe '#is_admin=' do
      before { user.is_admin = '1' }
      it { expect(user.has_role?(:account_admin, user.company)).to eql(true) }
    end

    describe '#mentor_name' do
      let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
      let(:user) { build(:user, mentor_id: mentor.id, company: company) }

      context 'mentor present' do
        it { expect(user.mentor_name).to eql(mentor.name) }
      end

      context 'mentor not present' do
        it { expect(mentor.mentor_name).to eql(nil) }
      end
    end
    #FIXED
    #FIXME Change as discussed.
    describe '#send_password_email' do
      let(:user) { build(:user) }
      let(:delayed_job) { mock_model(Delayed::Backend::ActiveRecord::Job) }

      before do
        allow(UserMailer).to receive(:delay).and_return(delayed_job)
        allow(delayed_job).to receive(:welcome_email).and_return(delayed_job)
      end

      it { expect(UserMailer).to receive(:delay).and_return(delayed_job) }
      #FIXED
      #FIXME -> Test with arguments
      it { expect(delayed_job).to receive(:welcome_email).with(user.email, user.password).and_return(delayed_job) }

      after { user.send(:send_password_email) }
    end

    describe '#ensure_only_one_account_owner' do
      let(:company) { create(:company) }
      let(:user) { create(:user, company: company) }

      before { company.reload }

      it { expect { user.add_role(:account_owner, company) }.to raise_error("There can be only one account owner") }
    end

    #FIXED
    #FIXME Check error_message also
    describe '#ensure_cannot_remove_account_owner_role' do
      let(:company) { create(:company) }

      it { expect { company.reload.owner.remove_role(:account_owner, company) }.to raise_error('Cannot remove account_owner role') }
    end

    describe '#display_user_details' do
      it { expect(user.send(:display_user_details)).to eql("#{ user.name } : #{ user.email }") }
    end

    describe 'usertask' do
      let(:track) { create(:track, company: company) }
      let(:user) { create(:user, company: company) }
      let(:task) { create(:task, track: track) }
      let(:usertask) { build(:usertask, user: user, task: task) }
      let(:exercise_task) { create(:exercise_task, reviewer: mentor, track: track) }
      let(:exercise_usertask) { build(:usertask, user: user, task: exercise_task) }


      describe '#current_task_state?' do
        context 'task not started' do
          it { expect(user.current_task_state?(task.id)).to eql(false) }
        end

        context 'task started' do
          before { usertask.save }
          it { expect(user.current_task_state?(task.id)).to eql(true) }
        end
      end

      describe '#current_task_state' do
        context 'task not started' do
          it { expect(Task::STATE[user.current_task_state(task.id)]).to eql(nil) }
        end

        context 'task started' do
          context 'theory task' do
            before { usertask.save }
            it { expect(Task::STATE[user.current_task_state(task.id)]).to eql('Started') }

            context 'task submitted' do
              it { expect{ usertask.submit! }.to change{ Task::STATE[user.current_task_state(task.id)] }.from('Started').to('Completed') }
            end
          end

          context 'exercise task' do
            before { exercise_usertask.save }
            it { expect(Task::STATE[user.current_task_state(exercise_task.id)]).to eql('Started') }

            context 'task submitted' do
              it { expect{ exercise_usertask.submit! }.to change{ Task::STATE[user.current_task_state(exercise_task.id)] }.from('Started').to('Pending for review') }

              context 'task accepted' do
                before { exercise_usertask.submit! }
                it { expect{ exercise_usertask.accept! }.to change{ Task::STATE[user.current_task_state(exercise_task.id)] }.from('Pending for review').to('Completed') }
              end

              context 'task accepted' do
                before { exercise_usertask.submit! }
                it { expect{ exercise_usertask.reject! }.to change{ Task::STATE[user.current_task_state(exercise_task.id)] }.from('Pending for review').to('Started') }
              end
            end
          end
        end
      end

      describe '#find_users_task' do
        context 'user has task' do
          before { usertask.save }
          it { expect(user.send(:find_users_task, task.id)).to eql(usertask) }
        end

        context 'user does not have task' do
          it { expect(mentor.send(:find_users_task, task.id)).to eql(nil) }
        end
      end
    end
  end
end
