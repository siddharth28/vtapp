require 'rails_helper'

describe Url do
  describe 'belongs_to' do
    it { should belong_to(:usertask) }
  end

  describe 'validation' do
    it { should validate_presence_of(:usertask) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:usertask_id).case_insensitive }
  end

  describe 'add_submission_comment' do
  end
end
