require 'rails_helper'

describe Track do
  let(:company) { create(:company) }
  let(:track) { create(:track, company: company.reload) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { create(:user, mentor_id: mentor.id, company: company) }

  before { company.reload.owner }

  describe 'constants' do
    it { Track.should have_constant(:ROLES) }
  end

  describe 'validation' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:references) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:instructions) }
    it { should validate_presence_of(:company) }
  end

  describe 'associations' do
    describe 'belongs_to' do
      it { should belong_to(:company) }
    end
  end

  describe 'attr_accessor' do
    describe '#owner_id' do
      it { expect(track.owner_id).to eql(11111) }
    end

    describe '#owner_id=' do
      before { track.owner_id = 9 }
      it { expect(track.owner_id).to eql(9) }
    end

    describe '#reviewer_id' do
      it { expect(track.reviewer_id).to eql(99999) }
    end

    describe '#reviewer_id=' do
      before { track.reviewer_id = 9 }
      it { expect(track.reviewer_id).to eq(9)  }
    end
  end

  describe '#instance methods' do
    describe '#assign_track_owner_role' do
      let(:track) { create(:track, company: company, owner_id: mentor.id) }
      let(:track_without_owner) { build(:track_without_owner) }

      context 'track_owner_given' do
        it { expect(track.owner_id).to eql(mentor.id) }
      end

      context 'track_owner_not_given' do
        before do
          track_without_owner.company_id = company.id
          track_without_owner.save
        end
        it { expect(track_without_owner.owner).to eql(company.owner) }
      end
    end

    let(:track) { create(:track, company: company, owner_id: user.id) }

    describe '#add_track_role' do
      context 'add reviewer' do
        before do
          track.add_track_role(:track_reviewer, user.id)
        end

        it { expect(track.reviewers.ids.include?(user.id)).to eql(true) }
      end

      context 'add owner' do
        before do
          track.add_track_role(:track_owner, user.id)
        end

        it { expect(track.owner).to eql(user) }
      end

      context 'user_id blank' do
        before do
          track.add_track_role(:track_reviewer, '')
        end

        #add_error rspec
        it { expect(track.errors[:base]).to eql(["Please enter a valid User"]) }
      end
    end

    describe '#remove_track_role' do
      context 'remove reviewer' do
        before do
          user.add_role(:track_reviewer, track)
          track.remove_track_role(:track_reviewer, user.id)
        end

        #example for find user
        it { expect(track.send(:find_user, user.id)).to eql(user) }
        it { expect(track.reviewers.ids.include?(user.id)).not_to eql(true) }
      end

      context 'remove owner' do
        before do
          user.add_role(:track_owner, track)
          track.remove_track_role(:track_owner, user.id)
        end

        #example for find user
        it { expect(track.send(:find_user, user.id)).to eql(user) }
        it { expect(track.owner).to be_nil }
      end

      context 'invalid owner' do
        before do
          track.remove_track_role(:track_owner, 123456)
        end
        it { expect(track.errors[:base]).to eql(["Please enter a valid User"]) }
      end
    end

    describe '#replace_owner' do
      context 'valid owner' do
        before do
          mentor.add_role(:track_owner, track)
          track.owner_id = user.id
        end
        it { expect{ track.send(:replace_owner)}.to change{ track.reload.owner }.to(user).from(mentor) }
      end

      context 'invalid owner' do
        before do
          track.owner_id = 123456
          track.send(:replace_owner)
        end
        it { expect(track.errors[:base]).to eql(["Please enter a valid User"]) }
      end

      context 'blank owner' do
        before do
          track.owner_id = ' '
          track.send(:replace_owner)
        end
        it { expect(track.errors[:base]).to eql(["Please enter a valid User"]) }
      end
    end

    describe '#company_users' do
      context 'user belongs to company' do
        it { expect(track.send(:company_users).include?(user)).to eql(true) }
      end

      context 'user belongs different company' do
        let(:company2) { create(:company, name: 'Company2', owner_email: 'owner_email2@owner.com') }
        let(:user2) { create(:user,  company: company2, email: 'User2@example.com') }

        before { user.company = company2 }

        it { expect(track.send(:company_users).include?(user2)).to eql(false) }
      end
    end
  end
end
