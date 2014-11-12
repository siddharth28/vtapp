require 'rails_helper'

describe Task do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }
  let(:track) { create(:track, company: company) }
  let(:task) { create(:task, track: track) }

  describe 'task states' do
    it { Task.should have_constant(:STATE) }
    it { expect(Task::STATE[:in_progress]).to eql('Started') }
    it { expect(Task::STATE[:submitted]).to eql('Pending for review') }
    it { expect(Task::STATE[:completed]).to eql('Completed') }
  end

  describe 'association' do
    describe 'belongs_to' do
      it { should belong_to(:track) }
    end

    describe 'has_many' do
      it { should have_many(:usertasks).dependent(:destroy) }
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

    describe '#need_review?' do

      context 'no exercise task' do
        it { expect(task.need_review?).to eq(false) }
      end

      context 'task with exercise task' do
        let(:exercise_task) { create(:exercise_task, track: track, reviewer: user) }
        let(:task) { exercise_task.task }

        it { expect(task.need_review?).to eq(true) }
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

    describe '#cannot_be_own_parent' do
      before do
        task.parent_id = task.id
        task.valid?
      end
      it { expect(task.errors[:parent]).to eql(['cannot be its own parent']) }
    end
  end
end