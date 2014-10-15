require 'rails_helper'

describe Track do
  let(:company) { create(:company) }
  let(:track) { build(:track) }
  let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
  let(:user) { build(:user, mentor_id: mentor.id, company: company) }

  describe 'validation' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:references) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:instructions) }

    describe 'uniqueness' do
      let(:company) { create(:company) }
      let(:track) { build(:track) }
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
    describe '#owner_email' do
      it { expect(track.owner_email).to eql('track_owner_email@owner.com') }
    end

    describe '#owner_email=' do
      before { track.owner_email= 'Changed Email' }
      it { expect(track.owner_email).to eql('Changed Email') }
    end

    describe '#owner_name' do
      it { expect(track.owner_name).to eql('Test Owner') }
    end

    describe '#owner_name=' do
      before { track.owner_name = 'Changed Name' }
      it { expect(track.owner_name).to eq('Changed Name')  }
    end
  end

  describe '#assign_track_owner_role' do
    let(:company) { create(:company) }
    let(:track_without_owner) { build(:track_without_owner) }
    let(:track) { build(:track) }
    let(:mentor) { create(:user, name: 'Mentor 1', email: 'Mentor@example.com', company: company) }
    let(:user) { build(:user, company: company) }

    context 'track_owner_given' do
      before do
        track.company_id = company.id
      end
      it { expect(track.owner_email).to eql('track_owner_email@owner.com') }
    end

    context 'track_owner_not_given' do
      before do
        track_without_owner.company_id = company.id
        track_without_owner.save
      end
      it { expect(track_without_owner.owner.first.email).to eql('owner_email@owner.com') }
    end
  end
end
