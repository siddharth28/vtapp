require 'rails_helper'

describe Usertask do
  let(:company) { create(:company) }
  let(:track) { build(:track) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { build(:user, mentor_id: mentor.id, company: company) }
  let(:task) { build(:task, )}

  describe 'associations' do
    describe 'belongs_to' do
      it { should belong_to(:user) }
      it { should belong_to(:task) }
    end

    describe 'has_many' do
      it { should belong_to(:comments).dependent(:destroy) }
      it { should have_many(:urls).dependent(:destroy) }
    end
  end
end
