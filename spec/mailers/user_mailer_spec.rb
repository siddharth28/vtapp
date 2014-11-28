require "rails_helper"

describe UserMailer do
  let(:user) { mock_model User, name: 'abc', email: 'abcd@abcd.com', password: "abcd" }
  let(:mail) { UserMailer.welcome_email(user.email, user.password) }
  let(:exercise_review_email) { UserMailer.exercise_review_email(usertask) }

  describe '#welcome_email' do
    it { expect(mail.subject).to eq 'Your Vtapp login details' }
    it { expect(mail.to).to eq [user.email] }
    it { expect(mail.body.raw_source.include?(user.email)).to eq true }
    it { expect(mail.body.raw_source.include?(user.password)).to eq true }
  end

end
