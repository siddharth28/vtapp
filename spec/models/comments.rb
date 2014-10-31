require 'rails_helper'

describe Comment do
  describe 'belongs_to' do
    it { should belong_to(:usertask) }
  end
end