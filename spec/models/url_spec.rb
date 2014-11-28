require 'rails_helper'

describe Url do
  let(:company) { create(:company) }
  let(:track) { create(:track, company: company.reload) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { create(:user, mentor_id: mentor.id, company: company.reload) }
  let(:task) { create(:task, track: track) }
  let(:usertask) { create(:usertask, user: user, task: task) }
  let(:url) { create(:url, usertask: usertask) }


  describe 'belongs_to' do
    it { should belong_to(:usertask) }
  end

  describe 'validation' do
    it { should validate_presence_of(:usertask) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:usertask_id) }
    it { should_not allow_value("test").for(:name) }
    it { should allow_value("http://test.com").for(:name) }
  end

  describe 'add_submission_comment' do
    it { expect{ url.add_submission_comment }.to change{ url.usertask.comments.count }.by(1) }
  end
end
