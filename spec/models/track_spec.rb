require 'rails_helper'

describe Track do
  let(:company) { create(:company) }
  let(:track) { build(:track) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { build(:user, mentor_id: mentor.id, company: company) }

  describe 'constants' do
    it { Track.should have_constant(:ROLES) }
  end

  describe 'validation' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:references) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:instructions) }

    describe 'uniqueness' do
      let(:company) { create(:company) }
      let(:track_owner_user) { create(:track_owner_user, company: company) }
      before do
        track_owner_user
        track.company_id = company.id
        track.save
      end
      it { should validate_uniqueness_of(:name).case_insensitive }
    end
  end

  describe 'associations' do
    describe 'belongs_to' do
      it { should belong_to(:company) }
    end
  end

  describe 'attr_accessor' do
    let(:company) { create(:company) }
    let(:user) { create(:new_user, company: company)}
    let(:track) { build(:track) }
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
      let(:company) { create(:company) }
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
      let(:company) { create(:company) }
      let(:track_without_owner) { build(:track_without_owner) }
      let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
      let(:user) { build(:user, company: company) }

      context 'track_owner_given' do
        before { track.company_id = company.id }
        it { expect(track.owner_id).to eql(11111) }
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

    describe '#add reviewer' do
      let(:company) { create(:company) }
      let(:user) { create(:user, company: company)}
      let(:track) { create(:track, company: company, owner_id: user.id, owner_name: user.name) }

      before do
        track.add_reviewer(user.id)
      end

      it { expect(track.reviewers.ids.include?(user.id)).to eql(true) }
    end

    describe '#remove reviewer' do
      let(:company) { create(:company) }
      let(:user) { create(:user, company: company)}
      let(:track) { create(:track, company: company, owner_id: user.id, owner_name: user.name) }

      before do
        user.add_role(:track_reviewer, track)
        track.remove_reviewer(user.id)
      end

      #example for find user
      it { expect(track.send(:find_user, user.id)).to eql(user) }
      it { expect(track.reviewers.ids.include?(user.id)).not_to eql(true) }
    end


    describe '#owner' do
      let(:company) { create(:company) }
      let(:user) { create(:user, company: company)}
      let(:track) { create(:track, company: company, owner_id: user.id, owner_name: user.name) }
      let(:user2) { create(:user, email: 'user2@gmail.com', company: company)}

      it { expect(track.owner).to eql(user) }
      it { expect(track.owner).not_to eql(user2) }
    end

    describe '#reviewer' do
      let(:company) { create(:company) }
      let(:user) { create(:user, company: company)}
      let(:track) { create(:track, company: company, owner_id: user.id, owner_name: user.name) }

      before do
        user.add_role(:track_reviewer, track)
      end

      it { expect(track.reviewers.ids.include?(user.id)).to eql(true) }

    end
  end
end
