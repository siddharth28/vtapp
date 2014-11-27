require 'rails_helper'

describe Usertask do
  let(:company) { create(:company) }
  let(:track) { create(:track, company: company) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { create(:user, mentor_id: mentor.id, company: company) }
  let(:task) { create(:task, track: track) }
  let(:usertask) { create(:usertask, user: user, task: task) }
  let(:exercise_task) { create(:exercise_task, reviewer: mentor, track: track) }
  let(:exercise_usertask) { create(:usertask, user: user, task: exercise_task.task) }
  let(:new_user) { create(:user, mentor_id: mentor.id, company: company) }

  before do
    company.reload.owner
    track.save
  end

  describe 'associations' do
    describe 'belongs_to' do
      it { should belong_to(:user) }
      it { should belong_to(:task) }
      it { should belong_to(:reviewer) }
    end
  end

  describe 'state_machine' do
    context 'exercise task' do
      context 'Initial state' do
        it { expect(exercise_usertask.aasm_state).to eql("not_started") }
        it { expect(exercise_usertask.aasm_state).not_to eql("submitted") }
        it { expect(exercise_usertask.aasm_state).not_to eql("completed") }
      end

      context 'start event' do
        it { expect { exercise_usertask.start! }.to change{ exercise_usertask.aasm_state }.from("not_started").to("in_progress") }
      end

      context 'submit event' do
        before { exercise_usertask.start! }
        it { expect { exercise_usertask.submit! }.to change{ exercise_usertask.aasm_state }.from("in_progress").to("submitted") }
      end

      context 'accepted event' do
        before do
          exercise_usertask.start!
          exercise_usertask.submit!
        end

        it { expect { exercise_usertask.accept! }.to change{ exercise_usertask.aasm_state }.from("submitted").to("completed") }
      end

      context 'rejected event' do
        before do
          exercise_usertask.start!
          exercise_usertask.submit!
        end
        it { expect { exercise_usertask.reject! }.to change{ exercise_usertask.aasm_state }.from("submitted").to("restart") }
      end
    end

    context 'normal theory task' do
      before { usertask.save }
      context 'Initial state' do
        it { expect(usertask.aasm_state).to eql("not_started") }
        it { expect(usertask.aasm_state).not_to eql("completed") }
      end

      context 'start event' do
        it { expect { usertask.start! }.to change{ usertask.aasm_state }.from("not_started").to("in_progress") }
      end

      context 'submit event' do
        before { usertask.start! }
        it { expect { usertask.submit! }.to change{ usertask.aasm_state }.from("in_progress").to("completed") }
      end
    end
  end

  describe '#instance_methods' do

    describe '#check_exercise?' do
      context 'normal theory exercise' do
        it { expect(usertask.send(:check_exercise?)).to eql(false) }
      end

      context 'exercise' do
        it { expect(exercise_usertask.send(:check_exercise?)).to eql(true) }
      end
    end

    describe '#add_start_time' do
      let(:usertask) { build(:usertask, user: user, task: task) }

      context 'normal theory task' do
        context 'before initialization task' do
          it { expect(usertask.start_time).to be_nil }
          it { expect(usertask.end_time).to be_nil }
        end

        context 'After task started' do
          before { usertask.start! }
          it { expect(usertask.start_time).not_to be_nil }
          it { expect(usertask.end_time).to be_nil }
        end

        context 'After task submitted' do
          before do
            usertask.start!
            usertask.submit!
          end
          it { expect(usertask.start_time).not_to be_nil }
          it { expect(usertask.end_time).not_to be_nil }
        end
      end

      context 'exercise task' do
        context 'before initialization task'
        it { expect(exercise_usertask.start_time).to be_nil }
        it { expect(exercise_usertask.end_time).to be_nil }
      end

      context 'After task started' do
        before { exercise_usertask.start! }
        it { expect(exercise_usertask.start_time).not_to be_nil }
        it { expect(exercise_usertask.end_time).to be_nil }
      end

      context 'After task submitted' do
        before do
          exercise_usertask.start!
          exercise_usertask.submit!
        end
        it { expect(exercise_usertask.start_time).not_to be_nil }
        it { expect(exercise_usertask.end_time).not_to be_nil }
      end
    end
  end
end
