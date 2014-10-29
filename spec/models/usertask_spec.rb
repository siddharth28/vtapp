require 'rails_helper'

describe Usertask do
  let(:company) { create(:company) }
  let(:track) { build(:track, company: company) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { create(:user, mentor_id: mentor.id, company: company) }
  let(:task) { create(:task, track: track) }
  let(:usertask) { build(:usertask, user: user, task: task) }

  describe 'associations' do
    describe 'belongs_to' do
      it { should belong_to(:user) }
      it { should belong_to(:task) }
    end
  end

  describe 'state_machine' do
    before { usertask.save }
    context 'Initial state' do
      it { expect(usertask.aasm_state).to eql("in_progress") }
      it { expect(usertask.aasm_state).not_to eql("submitted") }
      it { expect(usertask.aasm_state).not_to eql("completed") }
    end

    context 'submit event' do
      it { expect { usertask.submit! }.to change{ usertask.aasm_state }.from("in_progress").to("submitted") }

      context 'accepted event' do
        before { usertask.submit! }
        it { expect { usertask.accept! }.to change{ usertask.aasm_state }.from("submitted").to("completed") }
      end

      context 'rejected event' do
        before { usertask.submit! }
        it { expect { usertask.reject! }.to change{ usertask.aasm_state }.from("submitted").to("in_progress") }
      end
    end
  end

  describe 'attr_accessor' do
    let(:usertask) { build(:usertask, user: user, task: task, url: 'http', comment: 'Comment') }
    describe '#url' do
      it { expect(usertask.url).to eql('http') }
    end

    describe '#url=' do
      before { usertask.url = 'fttp' }
      it { expect(usertask.url).to eql('fttp') }
    end

    describe '#comment' do
      it { expect(usertask.comment).to eql('Comment') }
    end

    describe '#comment=' do
      before { usertask.comment = 'Comment1' }
      it { expect(usertask.comment).to eql('Comment1') }
    end
  end
end
