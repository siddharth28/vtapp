require 'rails_helper'

describe Task do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }
  let(:track) { create(:track, company: company) }
  let(:task) { create(:task, track: track) }

  describe 'association' do
    describe 'belongs_to' do
      it { should belong_to(:track) }
    end

    describe 'has_many' do
      it { should have_many(:usertasks) }
      it { should have_many(:users).through(:usertasks) }
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:track) }
  end

  describe '#instance_methods' do

    describe '#parent_title' do
      let(:child_task) { build(:task, parent: task) }

      it { expect(child_task.parent_title).to eq(task.title) }
    end

    describe '#need_review' do

      context 'no exercise task' do
        it { expect(task.need_review).to eq(0) }
      end

      context 'task with exercise task' do
        let(:exercise_task) { create(:exercise_task, track: track, reviewer: user) }
        let(:task) { exercise_task.task }

        it { expect(task.need_review).to eq(1) }
      end
    end

    describe '#dynamic instance methods' do
      context 'no exercise task' do

        [:instructions, :is_hidden, :sample_solution, :reviewer_id, :reviewer].each do |method|
          it { expect(task.send(method)).to eq(nil) }
        end

      end
      context 'task with exercise_task' do
        let(:exercise_task) { create(:exercise_task, track: track, reviewer: user) }
        let(:task) { exercise_task.task }

        [:instructions, :is_hidden, :sample_solution, :reviewer_id, :reviewer].each do |method|
          it { expect(task.send(method)).to eq(task.specific.send(method)) }
        end
      end
    end

    describe '#reviewer_name' do
      context 'no exercise task' do
        it { expect(task.reviewer_name).to eq(nil) }
      end
      context 'task with exercise_task' do
        let(:exercise_task) { create(:exercise_task, track: track, reviewer: user ) }
        let(:task) { exercise_task.task }

        it { expect(task.reviewer_name).to eq(task.specific.reviewer.name) }
      end
    end
  end
end