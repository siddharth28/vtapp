require "rails_helper"

describe UserMailer do
  let(:user) { mock_model User, name: 'abc', email: 'abcd@abcd.com', password: "abcd" }
  let(:mail) { UserMailer.welcome_email(user.email, user.password) }

  it { expect(mail.subject).to eq 'Welcome to My Awesome Site' }
  it { expect(mail.to).to eq [user.email] }
  it { expect(mail.body.raw_source).to eq "Welcome to vtapp.com, #{ user.email }
===============================================

You have successfully signed up to example.com,
your username is: #{ user.email }.

To login to the site, enter password: #{ user.password }.

Thanks for joining and have a great day!" }
end
