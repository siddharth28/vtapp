require 'rails_helper'

describe Role do

  describe 'associations' do
    describe 'has_many association' do
      it { should have_and_belong_to_many(:users).dependent(:nullify) }
    end

    describe 'belongs_to' do
      it { should belong_to(:resource) }
    end
  end
end
