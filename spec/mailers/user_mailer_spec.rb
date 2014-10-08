require "rails_helper"

describe UserMailer do
  let(:user) { mock_model User, name: 'abc', email: 'abcd@abcd.com', password: "abcd" }
  let(:mail) { UserMailer.welcome_email(user.email, user.password) }

  it { expect(mail.subject).to eq 'Welcome to My Awesome Site' }
  it { expect(mail.to).to eq [user.email] }
  it { expect(mail.body.raw_source.include?(user.email)).to eq true }
  it { expect(mail.body.raw_source.include?(user.password)).to eq true }
end
