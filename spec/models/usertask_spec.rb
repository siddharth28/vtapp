require 'rails_helper'

describe Usertask do
  let(:company) { create(:company) }
  let(:track) { build(:track, company: company) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { create(:user, mentor_id: mentor.id, company: company) }
  let(:task) { create(:task, track: track) }
  let(:usertask) { build(:usertask, user: user, task: task) }
  let(:exercise_task) { create(:exercise_task, track: track) }


  describe 'associations' do
    describe 'belongs_to' do
      it { should belong_to(:user) }
      it { should belong_to(:task) }
    end
  end

  describe 'state_machine' do
    context 'exercise task' do
      before { exercise_task.save }
      context 'Initial state' do
        it { expect(exercise_task.aasm_state).to eql("in_progress") }
        it { expect(exercise_task.aasm_state).not_to eql("submitted") }
        it { expect(exercise_task.aasm_state).not_to eql("completed") }
      end

      context 'submit event' do
        it { expect { exercise_task.exercise_submit! }.to change{ exercise_task.aasm_state }.from("in_progress").to("submitted") }

        context 'accepted event' do
          before { exercise_task.exercise_submit! }
          it { expect { exercise_task.accept! }.to change{ exercise_task.aasm_state }.from("submitted").to("completed") }
        end

        context 'rejected event' do
          before { exercise_task.exercise_submit! }
          it { expect { exercise_task.reject! }.to change{ exercise_task.aasm_state }.from("submitted").to("in_progress") }
        end
      end
    end
  end

  describe 'attr_accessor' do
    let(:exercise_task) { build(:exercise_task, user: user, task: task, url: 'http', comment: 'Comment') }
    describe '#url' do
      it { expect(exercise_task.url).to eql('http') }
    end

    describe '#url=' do
      before { exercise_task.url = 'fttp' }
      it { expect(exercise_task.url).to eql('fttp') }
    end

    describe '#comment' do
      it { expect(exercise_task.comment).to eql('Comment') }
    end

    describe '#comment=' do
      before { exercise_task.comment = 'Comment1' }
      it { expect(exercise_task.comment).to eql('Comment1') }
    end
  end
end
