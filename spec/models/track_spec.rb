require 'rails_helper'

describe Track do
  let(:company) { create(:company) }
  let(:track) { build(:track) }
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


    describe 'uniqueness' do
      let(:track_owner_user) { create(:track_owner_user, company: company) }

      before do
        track_owner_user
        track.company_id = company.id
        track.save
      end
      it { should validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }
    end
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

    describe '#owner_name' do
      it { expect(track.owner_name).to eql('Owner') }
    end

    describe '#owner_name=' do
      before { track.owner_name = 'Owner1' }
      it { expect(track.owner_name).to eql('Owner1') }
    end

    describe '#reviewer_id' do
      it { expect(track.reviewer_id).to eql(99999) }
    end

    describe '#reviewer_id=' do
      before { track.reviewer_id = 9 }
      it { expect(track.reviewer_id).to eq(9)  }
    end

    describe '#reviewer_name' do
      it { expect(track.reviewer_name).to eql('Reviewer') }
    end

    describe '#reviewer_name=' do
      before { track.reviewer_name = 'Reviewer1' }
      it { expect(track.reviewer_name).to eq('Reviewer1')  }
    end
  end

  describe '#class methods' do
    describe '#extract' do
      let(:track2) { build(:track, name: 'Track', company: company) }
      let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
      let(:user) { build(:user, company: company) }

      context 'track_runner_given' do
        before do
          track.company_id = company.id
          user.add_role(:track_runner, track)
          track.save
          user.save
        end

        it { expect(Track.extract('runner', user).include?(track)).to eql(true) }
        it { expect(Track.extract('runner', user).include?(track2)).to eql(false) }
      end

      context 'track_reviewer_given' do
        before do
          track.company_id = company.id
          user.add_role(:track_reviewer, track)
          track.save
          user.save
        end

        it { expect(Track.extract('reviewer', user).include?(track)).to eql(true) }
        it { expect(Track.extract('reviewer', user).include?(track2)).to eql(false) }
      end

      context 'track_owner_given' do
        before do
          track.company_id = company.id
          user.add_role(:track_owner, track)
          track.save
          user.save
        end

        it { expect(Track.extract('owner', user).include?(track)).to eql(true) }
        it { expect(Track.extract('owner', user).include?(track2)).to eql(false) }
      end
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
          track_without_owner.owner_id = 123456
          track_without_owner.save
        end
        it { expect(track_without_owner.owner.name).to eql('Test Owner') }
      end
    end

    let(:track) { create(:track, company: company, owner_id: user.id, owner_name: user.name) }

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
        it { expect(track.errors[:base]).to eql(["can't be blank"]) }
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
    end

    describe '#replace_owner' do
      before do
        track.add_track_role(:track_owner, mentor.id)
      end
      it { expect{ track.replace_owner(user.id) }.to change{ track.reload.owner }.to(user).from(mentor) }
    end

    describe '#replace_owner' do
      before do
        track.add_track_role(:track_owner, mentor.id)
      end
      it { expect{ track.replace_owner(user.id) }.to change{ track.reload.owner }.to(user).from(mentor) }
    end

    describe '#company_users' do
      context 'user belongs to company' do
        it { expect(track.send(:company_users).include?(user)).to eql(true) }
      end

      context 'user belongs different company' do
        let(:company2) { create(:company, name: 'Company2', owner_name: 'Test Owner', owner_email: 'owner_email2@owner.com') }
        let(:user2) { create(:user,  company: company2, email: 'User2@example.com') }

        before { user.company = company2 }

        it { expect(track.send(:company_users).include?(user2)).to eql(false) }
      end
    end
  end
end
