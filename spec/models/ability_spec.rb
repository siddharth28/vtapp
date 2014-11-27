require 'cancan/matchers'
require 'rails_helper'

describe Ability do

  let(:company) { create(:company) }
  let(:company2) { create(:company, name: 'other company', owner_email: 'newowner@owner.com') }
  let(:user) { create(:user, company: company) }
  let(:user1) { create(:user, email: 'other_email@email.com', company: company) }
  let(:user2) { create(:user, email: 'newemail@email.com', company: company2) }
  let(:track) { create(:track, company: company.reload) }
  let(:track2) { create(:track, company: company2.reload) }
  let(:ability) { Ability.new(user) }

  describe 'User' do

    describe 'super_admin abilities' do
      before(:each) do
        user.instance_variable_set(:@r_map, {})
        user.add_role(:super_admin)
      end

      it { expect(ability).to be_able_to(:read, user) }
      it { expect(ability).to be_able_to(:update, user) }
      it { expect(ability).to be_able_to(:manage, Company) }
    end

    describe 'Normal user abilities' do
      it { expect(ability).to be_able_to(:read, user) }
    end

    describe 'account_owner abilities' do
      let(:ability) { Ability.new(company.reload.owner) }

      context 'manage users, tracks of own company' do
        it { expect(ability).to be_able_to(:read, company.owner) }
        it { expect(ability).to be_able_to(:update, company.owner) }
        it { expect(ability).to be_able_to(:manage, user) }
        it { expect(ability).to be_able_to(:manage, track) }
      end

      context 'ability for users, tracks of other company' do
        it { expect(ability).not_to be_able_to(:manage, user2) }
        it { expect(ability).not_to be_able_to(:manage, track2) }
      end

      it { expect(ability).to be_able_to(:manage, Task) }
    end

    describe 'account_admin abilities' do
      before(:each) do
        user.instance_variable_set(:@r_map, {})
        user.add_role(:account_admin, company)
      end


      it { expect(ability).to be_able_to(:read, user) }
      it { expect(ability).to be_able_to(:update, user) }

      context 'manage users, tracks of own company' do
        it { expect(ability).to be_able_to(:read, user1) }
        it { expect(ability).to be_able_to(:create, user1) }
        it { expect(ability).to be_able_to(:autocomplete_user_name, user1) }
        it { expect(ability).to be_able_to(:autocomplete_user_department, user1) }
        it { expect(ability).to be_able_to(:manage, track) }
      end

      context 'ability for users, tracks of other company' do
        it { expect(ability).not_to be_able_to(:read, user2) }
        it { expect(ability).not_to be_able_to(:create, user2) }
        it { expect(ability).not_to be_able_to(:autocomplete_user_name, user2) }
        it { expect(ability).not_to be_able_to(:autocomplete_user_department, user2) }
        it { expect(ability).not_to be_able_to(:manage, track2) }
      end
      describe '#update' do
        context 'normal user' do
          it { expect(ability).to be_able_to(:update, user1) }
        end

        context 'account_owner' do
          it { expect(ability).not_to be_able_to(:update, company.owner) }
        end

        context 'account_admin' do
          before { user1.add_role(:account_admin, company) }
          it { expect(ability).not_to be_able_to(:update, user1) }
        end
      end

      it { expect(ability).to be_able_to(:manage, Task) }
    end

    describe 'track_owner abilities' do
      let(:track) { create(:track, company: company.reload, owner_id: user.id) }
      let(:task) { create(:task, track: track) }
      let(:task2) { create(:task, track: track2) }

      it { expect(ability).to be_able_to(:manage, track) }
      it { expect(ability).to be_able_to(:manage, task) }
      it { expect(ability).not_to be_able_to(:manage, track2) }
      it { expect(ability).not_to be_able_to(:manage, task2) }
    end

    describe 'track_runner_abilities' do
      let(:track) { create(:track, company: company.reload, owner_id: user.id) }
      let(:task) { create(:task, track: track) }
      let(:usertask) { create(:usertask, user: user, task: task) }
      let(:usertask2) { create(:usertask, user: user2, task: task) }
      before { user.add_role(:track_runner, track) }

      it { expect(ability).to be_able_to(:read, track) }
      it { expect(ability).to be_able_to(:start, usertask) }
      it { expect(ability).not_to be_able_to(:read, usertask) }
      it { expect(ability).not_to be_able_to(:submit, usertask) }

      it { expect(ability).not_to be_able_to(:read, track2) }
      it { expect(ability).not_to be_able_to(:manage, usertask2) }

      context 'started task' do
        before do
          usertask.start!
          usertask2.start!
        end

        it { expect(ability).to be_able_to(:read, usertask) }
        it { expect(ability).to be_able_to(:submit_url, usertask) }
        it { expect(ability).to be_able_to(:submit_comment, usertask) }
        it { expect(ability).not_to be_able_to(:read, usertask2) }
        it { expect(ability).not_to be_able_to(:submit_url, usertask2) }
      end
    end
  end
end
