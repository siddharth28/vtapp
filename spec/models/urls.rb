require 'rails_helper'

describe Urls do
  describe 'belongs_to' do
    it { should belong_to(:usertask) }
    it { should belong_to(:commentor).class_name(User) }
  end
end
