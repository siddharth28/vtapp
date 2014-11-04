require 'rails_helper'

describe Usertask do
  let(:company) { create(:company) }
  let(:track) { build(:track, company: company) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { create(:user, mentor_id: mentor.id, company: company) }
  let(:task) { create(:task, track: track) }
  let(:usertask) { build(:usertask, user: user, task: task) }
  let(:exercise_task) { create(:exercise_task, reviewer: mentor, track: track) }
  let(:exercise_usertask) { build(:usertask, user: user, task: exercise_task) }


  describe 'associations' do
    describe 'belongs_to' do
      it { should belong_to(:user) }
      it { should belong_to(:task) }
    end
  end

  describe 'state_machine' do
    context 'exercise task' do
      before { exercise_usertask.save }
      context 'Initial state' do
        it { expect(exercise_usertask.aasm_state).to eql("in_progress") }
        it { expect(exercise_usertask.aasm_state).not_to eql("submitted") }
        it { expect(exercise_usertask.aasm_state).not_to eql("completed") }
      end

      context 'submit event' do
        it { expect { exercise_usertask.submit! }.to change{ exercise_usertask.aasm_state }.from("in_progress").to("submitted") }

        context 'accepted event' do
          before { exercise_usertask.submit! }

          it { expect { exercise_usertask.accept! }.to change{ exercise_usertask.aasm_state }.from("submitted").to("completed") }
        end

        context 'rejected event' do
          before { exercise_usertask.submit! }
          it { expect { exercise_usertask.reject! }.to change{ exercise_usertask.aasm_state }.from("submitted").to("in_progress") }
        end
      end
    end

    context 'normal theory task' do
      before { usertask.save }
      context 'Initial state' do
        it { expect(usertask.aasm_state).to eql("in_progress") }
        it { expect(usertask.aasm_state).not_to eql("completed") }
      end

      context 'submit event' do
        it { expect { usertask.submit! }.to change{ usertask.aasm_state }.from("in_progress").to("completed") }
      end
    end
  end

  describe '#instance_methods' do
    describe 'attr_accessor' do
      let(:usertask) { build(:usertask, user: user, task: task, url: 'http', comment: 'Comment') }
      describe '#url' do
        it { expect(usertask.url).to eql('http') }
      end

      describe '#url=' do
        before { usertask.url = 'fttp' }
        it { expect(usertask.url).to eql('fttp') }
      end

      describe '#comment' do
        it { expect(usertask.comment).to eql('Comment') }
      end

      describe '#comment=' do
        before { usertask.comment = 'Comment1' }
        it { expect(usertask.comment).to eql('Comment1') }
      end
    end

    describe '#submit_task' do
      context 'normal theory task' do
        before { usertask.save }
        it { expect{ usertask.submit_task }.to change{ user.usertasks.find(usertask.id).aasm_state }.from("in_progress").to("completed") }
      end

      context 'exercise' do
        before { exercise_usertask.save }
        it { expect{ exercise_usertask.submit_task({ url: 'http://abc.com', comment: 'Comment' }) }.to change{ user.usertasks.find(exercise_usertask.id).aasm_state }.from("in_progress").to("submitted") }
        it { expect( exercise_usertask.submit_task({ url: 'http://abc.com', comment: 'Comment' })).to eql(true) }
      end
    end

    describe '#check_exercise?' do
      context 'normal theory exercise' do
        before { usertask.save }
        it { expect(usertask.check_exercise?).to eql(false) }
      end

      context 'exercise' do
        before { exercise_usertask.save }
        it { expect(exercise_usertask.check_exercise?).to eql(true) }
      end
    end

    describe '#add_start_time' do
      context 'normal theory task' do
        context 'before initialization task' do
          it { expect(usertask.start_time).to be_nil }
          it { expect(usertask.end_time).to be_nil }
        end

        context 'After task started' do
          before { usertask.save }
          it { expect(usertask.start_time).not_to be_nil }
          it { expect(usertask.end_time).to be_nil }
        end

        context 'After task submitted' do
          before { usertask.submit! }
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
        before { exercise_usertask.save }
        it { expect(exercise_usertask.start_time).not_to be_nil }
        it { expect(exercise_usertask.end_time).to be_nil }
      end

      context 'After task submitted' do
        before { exercise_usertask.submit! }
        it { expect(exercise_usertask.start_time).not_to be_nil }
        it { expect(exercise_usertask.end_time).not_to be_nil }
      end
    end
  end
end
