require 'rails_helper'

describe ExerciseTask do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }
  let(:track) { create(:track, company: company.reload) }
  let(:exercise_task) { build(:exercise_task, track: track, reviewer: user) }

  describe 'association' do
    it { should belong_to(:reviewer).class_name(User) }
    it { should have_attached_file(:sample_solution) }
  end

  describe 'validations' do
    it { should validate_presence_of(:reviewer) }
    it { should validate_attachment_content_type(:sample_solution).allowing('application/zip') }
  end

  describe '#reviewer_name' do
    it { expect(exercise_task.reviewer_name).to eq(user.name) }
  end
end